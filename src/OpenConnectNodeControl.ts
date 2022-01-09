import { SSHExecCommandResponse } from "node-ssh";
import path from "path";
import NodeControl, { NodeSystemStats } from "./NodeControl";
import { parseSystemDStatusOutput, SystemDResult } from "./parser";

export class OpenConnectNodeControl extends NodeControl {
  getSystemStats(): Promise<NodeSystemStats> {
    return this.getSystemStatsByVpnType("openconnect");
  }

  installServer(): Promise<SSHExecCommandResponse> {
    return this.runScriptFile(path.join(__dirname, "./scripts/install_oc.sh"));
  }

  getServiceStatus(): Promise<SystemDResult> {
    return this.getServiceStatusByServiceName("ocserv");
  }

  restartServer(): Promise<SSHExecCommandResponse> {
    return this.runShellCommand("systemctl restart ocserv");
  }

  stopServer(): Promise<SSHExecCommandResponse> {
    return this.runShellCommand("systemctl stop ocserv");
  }
}
