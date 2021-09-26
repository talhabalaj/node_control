import path from "path";
import { parseSystemDStatusOutput } from "./parser";
import NodeControl, { NodeControlBaseConfig, NodeSystemStats } from "./NodeControl";

interface ShadowSocksNodeConfig extends NodeControlBaseConfig {
  ssPassword: string;
  ssPort: number;
}

export class ShadowSocksNodeControl extends NodeControl {
  async installServer() {
    const response = await this.runScriptFile(path.join(__dirname, "./scripts/install_ss.sh"), {
      PORT: this.config.ssPort,
      PASSWORD: this.config.ssPassword,
    });

    return response;
  }

  constructor(protected config: ShadowSocksNodeConfig) {
    super(config);
  }

  async getServiceStatus() {
    const response = await this.runScriptFile(path.join(__dirname, "./scripts/get_status.sh"));

    if (!response.stdout) return parseSystemDStatusOutput(response.stderr);

    return parseSystemDStatusOutput(response.stdout);
  }

  async restartServer() {
    const r = await this.runShellCommand(`systemctl restart ssserver`);
    return r;
  }

  async stopServer() {
    const r = await this.runShellCommand(`systemctl stop ssserver`);
    return r;
  }

  async getSystemStats(port: number) {
    const response = await this.runScriptFile(
      path.join(__dirname, "./scripts/get_system_stats.sh"),
      {
        NODE_TYPE: "shadowsocks",
        NODE_PORT: port,
      }
    );

    if (response.stderr) {
      throw Error(`Some error occurred while getting stats ${response.stderr}`);
    }

    return JSON.parse(response.stdout) as NodeSystemStats;
  }
}
