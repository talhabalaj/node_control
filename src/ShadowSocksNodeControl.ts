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
    return this.getServiceStatusByServiceName("ssserver");
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
    return super.getSystemStatsByVpnType("shadowsocks", port);
  }
}
