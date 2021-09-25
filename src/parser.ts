import fs from "fs/promises";

export interface SystemDResult {
  loaded: "loaded" | "not-found" | "error";
  active: "active" | "inactive";
  mainPid: number;
  tasks: number;
  memory: string;
}

const toCamelCase = (string: string) => {
  return string
    .toLowerCase()
    .split(" ")
    .map((value, index) => (index !== 0 ? `${value[0].toUpperCase()}${value.substring(1)}` : value))
    .join("");
};

export const parseSystemDStatusOutput = (string: string): SystemDResult => {
  const lines = string.split("\n");

  if (lines.length === 1) {
    return {
      loaded: "not-found",
      active: "inactive",
      mainPid: -1,
      tasks: -1,
      memory: "",
    };
  }

  lines.shift();

  const props: any = {};

  for (const line of lines) {
    const trimmed = line.trim();
    const result = /^(?<key>[A-Za-z\s]+)\: (?<value>[A-Za-z0-9\.]+)(?<prop>.*)$/g.exec(trimmed);

    if (result && result.groups) {
      props[toCamelCase(result.groups.key)] = Number(result.groups.value) || result.groups.value;
    }
  }

  return props as SystemDResult;
};
