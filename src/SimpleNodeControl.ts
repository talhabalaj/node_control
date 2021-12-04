import { SSHExecCommandResponse } from "node-ssh";
import NodeControl, { NodeSystemStats } from "./NodeControl";
import { SystemDResult } from "./parser";

export class SimpleNodeControl extends NodeControl {
  getSystemStats(...args: any[]): Promise<NodeSystemStats> {
    throw new Error("Method not implemented.");
  }
  installServer(): Promise<SSHExecCommandResponse> {
    throw new Error("Method not implemented.");
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
