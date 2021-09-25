import path from "path";
import { parseSystemDStatusOutput } from "../parser";
import NodeControl, { NodeControlBaseConfig } from "../NodeControl/NodeControl";

interface ShadowSocksNodeConfig extends NodeControlBaseConfig {
  ssPassword: string;
  ssPort: number;
}

export class ShadowSocksNode extends NodeControl {
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
}
