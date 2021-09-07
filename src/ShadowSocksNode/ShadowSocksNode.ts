import { NodeSSH } from "node-ssh";
import fs from "fs/promises";
import path from "path";
import { parseSystemDStatusOutput } from "./parser";

interface ShadowSocksNodeConfig {
  ssPassword: string;
  ssPort: number;
  sshUser: string | "root";
  sshPassword: string;
  sshHost: `${number}.${number}.${number}.${number}` | string;
}

export class ShadowSocksNode {
  sshClient: NodeSSH = new NodeSSH();

  get isConnected() {
    return this.sshClient.isConnected;
  }

  private async ensureConnected() {
    if (this.isConnected()) return true;

    await this.sshClient.connect({
      host: this.config.sshHost,
      port: 22,
      password: this.config.sshPassword,
      username: this.config.sshUser,
    });
  }

  constructor(private config: ShadowSocksNodeConfig) {}

  private async runSriptFile(filePath: string, env?: Record<string, any>) {
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

  async installServer() {
    const response = await this.runSriptFile(path.join(__dirname, "./scripts/install_ss.sh"), {
      PORT: this.config.ssPort,
      PASSWORD: this.config.ssPassword,
    });

    return response.code === null;
  }

  async getStatus() {
    const response = await this.runSriptFile(path.join(__dirname, "./scripts/get_status.sh"));

    if (!response.stdout) return null;

    return parseSystemDStatusOutput(response.stdout);
  }

  async runShellCommand(command: string) {
    return this.sshClient.execCommand(command);
  }

  async restartServer() {
    const r = await this.runShellCommand(`systemctl restart ssserver`);
    return r.code === null;
  }
}
