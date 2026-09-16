const fs = require('fs');
const path = require('path');

const distDirectory = path.resolve(__dirname, '..', 'dist');

fs.rmSync(distDirectory, { recursive: true, force: true });
