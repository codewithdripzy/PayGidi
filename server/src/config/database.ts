import mongoose from 'mongoose';
import * as dotenv from 'dotenv';

class Database {
    private name: string;
    private host: string;
    private port: string;
    private user: string;
    private password: string;

    constructor() {
        dotenv.config();

        this.name = process.env.DB_NAME ?? '';
        this.host = process.env.DB_HOST ?? '';
        this.port = process.env.DB_PORT ?? '';
        this.user = process.env.DB_USER ?? '';
        this.password = process.env.DB_PASSWORD ?? '';
    }

    async getConnection() {
        try {
            return await mongoose
                .connect(
                    `mongodb+srv://${this.user}:${this.password}@${this.host}/${this.name}?retryWrites=true&w=majority&family=4&appName=workstudio-cluster`,
                    { serverApi: { version: '1', strict: true, deprecationErrors: true } }
                )
                .then(async () => {
                    await this.ensureAssistantWidgetKeyIndex();
                    console.log('Connected to the database');
                });
        } catch (error) {
            console.error('Failed to connect to the database:', error);
            throw error;
        }
    }

    private async ensureAssistantWidgetKeyIndex() {
        const collection = mongoose.connection.collection('assistants');
        const indexName = 'deployment.widgetKey_1';
        const indexes = await collection.indexes();
        const existing = indexes.find((index) => index.name === indexName);

        const hasCorrectPartialUniqueIndex =
            Boolean(existing?.unique) &&
            Boolean(existing?.partialFilterExpression) &&
            (existing?.partialFilterExpression as Record<string, unknown>)['deployment.widgetKey'] !== undefined;

        if (existing && !hasCorrectPartialUniqueIndex) {
            await collection.dropIndex(indexName);
        }

        if (!hasCorrectPartialUniqueIndex) {
            await collection.createIndex(
                { 'deployment.widgetKey': 1 },
                {
                    name: indexName,
                    unique: true,
                    partialFilterExpression: {
                        'deployment.widgetKey': { $type: 'string' },
                    },
                }
            );
        }
    }
}

export default Database;
