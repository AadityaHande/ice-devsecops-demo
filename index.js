const minimist = require('minimist');

const args = minimist(process.argv.slice(2));
const name = typeof args.name === 'string' && args.name.trim() ? args.name : 'Developer';

console.log(`Hello, ${name}! This sample application is part of the ICE DevSecOps demonstration.`);
