import { Dexie } from "dexie";

type Project = {
  id?: number;
  name: string;
  code: string;
  thumbnail: ArrayBuffer;
  channels: ArrayBuffer[];
};

class ProjectDatabase extends Dexie {
  public readonly projects: Dexie.Table<Project, number>;

  constructor(databaseName: string) {
    super(databaseName);

    this.version(1).stores({
      projects: "++id, name",
    });

    this.projects = this.table("projects");
  }
}

const database = new ProjectDatabase("wgsl-playground-database");

export { ProjectDatabase, database };
export type { Project };
