import { BaseConfig, ConfigArguments } from "jsr:@shougo/ddc-vim@10.1.0/config";

export class Config extends BaseConfig {
  override async config(args: ConfigArguments): Promise<void> {
    args.contextBuilder.patchGlobal({
      ui: "pum",
      autoCompleteEvents: [
        "TextChangedI",
      ],
      sources: [
        "skkeleton",
        "skkeleton_okuri",
      ],
      sourceOptions: {
        skkeleton: {
          mark: "skk",
          matchers: [],
          sorters: [],
          minAutoCompleteLength: 1,
          isVolatile: true,
        },
        skkeleton_okuri: {
          mark: "skk*",
          matchers: [],
          sorters: [],
          minAutoCompleteLength: 2,
          isVolatile: true,
        },
      },
    });
  }
}
