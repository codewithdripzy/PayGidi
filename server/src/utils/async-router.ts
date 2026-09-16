import { Router } from 'express';

type Layer = {
  route?: { stack: Layer[] };
  handle?: any;
  stack?: Layer[];
};

const wrap = (handler: any) => {
  if (handler.__paygidiAsyncHandler) return handler;

  const wrapped = (request: any, response: any, next: any) => {
    try {
      return Promise.resolve(handler(request, response, next)).catch(next);
    } catch (error) {
      return next(error);
    }
  };

  wrapped.__paygidiAsyncHandler = true;
  return wrapped;
};

export const wrapRouter = (router: Router): Router => {
  for (const layer of (router as any).stack as Layer[]) {
    if (layer.route?.stack) {
      for (const routeLayer of layer.route.stack) {
        routeLayer.handle = wrap(routeLayer.handle);
      }
    } else if (layer.handle?.stack) {
      wrapRouter(layer.handle);
    }
  }

  return router;
};
