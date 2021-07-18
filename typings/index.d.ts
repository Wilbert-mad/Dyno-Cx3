export namespace DynoCC {
  class Compiler {
    constructor(data: {
      args: string[];
      server: {
        id: string;
        name: string;
        icon: string | null;
        memberCount: number;
        createdAt: number;
        ownerId: string;
        region: string;
      };
      user: {
        id: string;
        username: string;
        discriminator: string;
        nick: string | null;
        game: any;
        avatar: string | null;
        createdAt: number;
        joinedAt: number;
      };
      channel: { id: string; name: string };
      mentionValidator?: (type: 'role' | 'user' | 'channel', name: string) => string;
    });
    compile(str: string): string;
    private _allowEveryOne: boolean;
    private __checkData(data: any): void;
  }
}
