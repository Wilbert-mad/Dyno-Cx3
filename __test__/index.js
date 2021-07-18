const dcc = require('../dist/index');
const compiler = new dcc.compiler({
  args: ['World'],
  user: {
    id: '1234',
    username: 'puppet',
    discriminator: '1234',
    nick: null,
    game: null,
    avatar: null,
    createdAt: 0,
    joinedAt: 0,
  },
  server: {
    id: '0987',
    name: 'Unknown',
    icon: null,
    memberCount: 2,
    ownerId: '1234',
    createdAt: 0,
    region: 'en-US',
  },
  channel: {
    id: '8765',
    name: 'main',
  },
});

console.log(compiler.compile(`Hello $1`));
