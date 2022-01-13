import { SSHExecCommandResponse } from "node-ssh";
import path from "path";
import NodeControl, { NodeSystemStats } from "./NodeControl";
import { SystemDResult } from "./parser";

export class ProxyNodeControl extends NodeControl {
  getSystemStats(...args: any[]): Promise<NodeSystemStats> {
    throw new Error("Method not implemented.");
  }

  installServer(domain: string): Promise<SSHExecCommandResponse> {
    return this.runScriptFile(
      path.join(__dirname, "./scripts/install_proxy.sh"),
      {
        domain,
      }
    );
  }

  getServiceStatus(): Promise<SystemDResult> {
    throw new Error("Method not implemented.");
  }

  restartServer(): Promise<SSHExecCommandResponse> {
    throw new Error("Method not implemented.");
  }

  stopServer(): Promise<SSHExecCommandResponse> {
    throw new Error("Method not implemented.");
  }
}
