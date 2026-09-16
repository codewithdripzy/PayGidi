import prisma from '../config/prisma';

type PrismaOptions = { json?: string[] };

const numericFields = new Set([
  'amount',
  'balance',
  'escrowBalance',
  'targetAmount',
  'currentAmount',
  'contributionAmount',
  'trustScore',
  'principalAmount',
  'settledAmount',
  'feeCharged',
  'currentMembers',
  'maxMembers',
]);

const toPublic = (row: Record<string, any>, json: Set<string>) => {
  const result: Record<string, any> = { ...row };
  for (const key of Object.keys(result)) {
    if (
      numericFields.has(key) &&
      result[key] !== null &&
      result[key] !== undefined
    )
      result[key] = Number(result[key]);
    if (json.has(key) && typeof result[key] === 'string')
      result[key] = JSON.parse(result[key]);
  }
  result._id = result.id;
  return result;
};

class PrismaDocument {
  [key: string]: any;

  constructor(
    private readonly delegate: any,
    private readonly json: Set<string>,
    values: Record<string, any>,
  ) {
    Object.assign(this, toPublic(values, json));
  }

  toObject() {
    return { ...this };
  }

  async save() {
    const data = Object.fromEntries(
      Object.entries(this).filter(
        ([key]) =>
          !key.startsWith('_') &&
          !['id', 'createdAt', 'updatedAt'].includes(key),
      ),
    );
    const saved = await this.delegate.update({ where: { id: this.id }, data });
    Object.assign(this, toPublic(saved, this.json));
    return this;
  }
}

class PrismaQuery<T> implements PromiseLike<T> {
  private orderBy: Record<string, 'asc' | 'desc'> | undefined;
  private excluded: string[] = [];

  constructor(
    private readonly execute: (
      orderBy?: Record<string, 'asc' | 'desc'>,
      excluded?: string[],
    ) => Promise<T>,
  ) {}

  sort(value: Record<string, 1 | -1>) {
    const [field, direction] = Object.entries(value)[0];
    this.orderBy = { [field]: direction === -1 ? 'desc' : 'asc' };
    return this;
  }

  select(value: string) {
    this.excluded = value
      .split(' ')
      .filter((field) => field.startsWith('-'))
      .map((field) => field.slice(1));
    return this;
  }

  then<TResult1 = T, TResult2 = never>(
    onfulfilled?: ((value: T) => TResult1 | PromiseLike<TResult1>) | null,
    onrejected?: ((reason: any) => TResult2 | PromiseLike<TResult2>) | null,
  ) {
    return this.execute(this.orderBy, this.excluded).then(
      onfulfilled,
      onrejected,
    );
  }
}

const toPrismaWhere = (filter: Record<string, any>): Record<string, any> => {
  const where: Record<string, any> = {};
  for (const [key, value] of Object.entries(filter || {})) {
    if (key === '$or') {
      where.OR = value.map((item: Record<string, any>) => toPrismaWhere(item));
      continue;
    }
    const field = key === '_id' ? 'id' : key;
    if (key.includes('.')) {
      const [root, ...path] = key.split('.');
      where[root] = { path, equals: value };
    } else if (value && typeof value === 'object' && '$gt' in value) {
      where[field] = { gt: value.$gt };
    } else {
      where[field] = value;
    }
  }
  return where;
};

export function createPrismaModel(
  delegateName: string,
  options: PrismaOptions = {},
) {
  const delegate = (prisma as any)[delegateName];
  const json = new Set(options.json || []);
  const make = (row: Record<string, any>) =>
    new PrismaDocument(delegate, json, row);

  const find = (filter: Record<string, any> = {}) =>
    new PrismaQuery<any[]>(async (orderBy, excluded = []) => {
      const rows = await delegate.findMany({
        where: toPrismaWhere(filter),
        orderBy: orderBy || { createdAt: 'desc' },
      });
      return rows.map((row: Record<string, any>) => {
        const document = make(row);
        for (const field of excluded) delete document[field];
        return document;
      });
    });

  const findOne = (filter: Record<string, any> = {}) =>
    new PrismaQuery<any>(async () => {
      const row = await delegate.findFirst({ where: toPrismaWhere(filter) });
      return row ? make(row) : null;
    });

  const create = async (data: Record<string, any>) => {
    const input = { ...data };
    delete input._id;
    return make(await delegate.create({ data: input }));
  };

  const update = async (
    filter: Record<string, any>,
    changes: Record<string, any>,
    upsert = false,
  ) => {
    const existing: any = await findOne(filter);
    if (!existing && upsert)
      return create({
        ...(changes.$setOnInsert || {}),
        ...(changes.$set || {}),
      });
    if (!existing) return null;
    const data = { ...(changes.$set || {}) };
    for (const [field, value] of Object.entries(changes.$inc || {}))
      data[field] = { increment: value };
    return make(await delegate.update({ where: { id: existing.id }, data }));
  };

  return {
    create,
    find,
    findOne,
    findById: (id: string) => findOne({ _id: id }),
    findOneAndUpdate: (filter: any, changes: any, options: any = {}) =>
      new PrismaQuery<any>(async () =>
        update(filter, changes, Boolean(options.upsert)),
      ),
    updateOne: async (filter: any, changes: any) => ({
      modifiedCount: (await update(filter, changes)) ? 1 : 0,
    }),
    updateMany: async (filter: any, changes: any) => ({
      modifiedCount: (await update(filter, changes)) ? 1 : 0,
    }),
    deleteOne: async (filter: any) => ({
      deletedCount: await delegate
        .deleteMany({ where: toPrismaWhere(filter) })
        .then((result: any) => result.count),
    }),
    deleteMany: async (filter: any) => ({
      deletedCount: await delegate
        .deleteMany({ where: toPrismaWhere(filter) })
        .then((result: any) => result.count),
    }),
    countDocuments: (filter: any) =>
      delegate.count({ where: toPrismaWhere(filter) }),
  };
}
