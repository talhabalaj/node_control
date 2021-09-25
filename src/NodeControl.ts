import { NodeSSH, SSHExecCommandResponse } from "node-ssh";
import path from "path";
import fs from "fs/promises";
import { SystemDResult } from "./parser";

export interface NodeControlBaseConfig {
  sshHost: string;
  sshPassword: string;
  sshUser: string;
}

interface NodeSystemStats {
  mem: string;
  cpu: string;
  rx: number;
  tx: number;
  connected_users: number;
  interface: string;
}

export default abstract class NodeControl {
  protected sshClient: NodeSSH = new NodeSSH();

  get isConnected() {
    return this.sshClient.isConnected;
  }

  protected async ensureConnected() {
    if (this.isConnected()) return;

    await this.sshClient.connect({
      host: this.config.sshHost.trim(),
      port: 22,
      password: this.config.sshPassword.trim(),
      username: this.config.sshUser.trim(),
    });
  }

  constructor(protected config: NodeControlBaseConfig) {}

  protected async runScriptFile(filePath: string, env?: Record<string, any>) {
    await this.ensureConnected();
    await fs.access(filePath);

    const scriptPath = filePath;
    const remoteScriptPath = path.join("/etc/mycode/", scriptPath);

    await this.sshClient.putFile(scriptPath, remoteScriptPath);

    const envString =
      env &&
      Object.keys(env)
        .map((key) => `${key}=${env[key]}`)
        .join(" ");

    return this.runShellCommand(`${envString || ""} bash ${remoteScriptPath}`);
  }

  async runShellCommand(command: string) {
    await this.ensureConnected();
    return this.sshClient.execCommand(command);
  }

  async getSystemStats() {
    const response = await this.runScriptFile(
      path.join(__dirname, "./scripts/get_system_stats.sh")
    );

    if (response.stderr) {
      throw Error(`Some error occurred while getting stats ${response.stderr}`);
    }

    return JSON.parse(response.stdout) as NodeSystemStats;
  }

  abstract installServer(): Promise<SSHExecCommandResponse>;
  abstract getServiceStatus(): Promise<SystemDResult>;
  abstract restartServer(): Promise<SSHExecCommandResponse>;
  abstract stopServer(): Promise<SSHExecCommandResponse>;
}