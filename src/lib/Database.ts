import { Dexie } from "dexie";

type Project = {
  id?: number;
  name: string;
  code: string;
  thumbnail: ArrayBuffer;
  channels: [ArrayBuffer, ArrayBuffer, ArrayBuffer, ArrayBuffer];
};

class ProjectDatabase extends Dexie {
  public readonly projects: Dexie.Table<Project, number>;
  public readonly showcase: Dexie.Table<Project, number>;

  constructor(databaseName: string) {
    super(databaseName);

    this.version(1).stores({
      projects: "++id, name",
      showcase: "++id, name",
    });

    this.projects = this.table("projects");
    this.showcase = this.table("showcase");
  }
}

const database = new ProjectDatabase("wgsl-playground-database");

export { ProjectDatabase, database };
export type { Project };
