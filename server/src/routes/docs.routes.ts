import { Router } from 'express';
import { openApiDocument } from '../docs/openapi';

const docsRouter = Router();

docsRouter.get('/openapi.json', (_request, response) =>
  response.json(openApiDocument),
);
docsRouter.get('/', (_request, response) => {
  response
    .type('html')
    .send(
      `<!doctype html><html><head><title>PayGidi API Docs</title><link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css"></head><body><div id="swagger-ui"></div><script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script><script>window.onload=()=>SwaggerUIBundle({url:'/docs/openapi.json',dom_id:'#swagger-ui'});</script></body></html>`,
    );
});

export default docsRouter;
