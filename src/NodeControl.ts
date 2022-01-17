import { NodeSSH, SSHExecCommandResponse } from "node-ssh";
import path from "path";
import fs from "fs/promises";
import { parseSystemDStatusOutput, SystemDResult } from "./parser";

export interface NodeControlBaseConfig {
  sshHost: string;
  sshPassword: string;
  sshUser: string;
}

export interface NodeSystemStats {
  mem: number;
  cpu: number;
  rx: number;
  tx: number;
  connected_users: number;
  interface: string;
  service_status: string;
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
      readyTimeout: 40000,
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

  async reboot() {
    await this.runShellCommand("shutdown -r now");
    this.dispose();
  }

  dispose() {
    this.sshClient.dispose();
  }

  abstract getSystemStats(...args: any[]): Promise<NodeSystemStats>;
  abstract installServer(...args: any[]): Promise<SSHExecCommandResponse>;
  abstract getServiceStatus(): Promise<SystemDResult>;
  abstract restartServer(): Promise<SSHExecCommandResponse>;
  abstract stopServer(): Promise<SSHExecCommandResponse>;

  protected async getSystemStatsByVpnType(
    type: "shadowsocks" | "openconnect",
    port?: number
  ): Promise<NodeSystemStats> {
    const response = await this.runScriptFile(
      path.join(__dirname, "./scripts/get_system_stats.sh"),
      {
        NODE_TYPE: type,
        NODE_PORT: port,
      }
    );

    if (response.stderr) {
      throw Error(`Some error occurred while getting stats ${response.stderr}`);
    }

    return JSON.parse(response.stdout) as NodeSystemStats;
  }

  protected async getServiceStatusByServiceName(
    serviceName: string
  ): Promise<SystemDResult> {
    const response = await this.runShellCommand(
      `systemctl status ${serviceName}`
    );

    if (!response.stdout) return parseSystemDStatusOutput(response.stderr);

    return parseSystemDStatusOutput(response.stdout);
  }
}
