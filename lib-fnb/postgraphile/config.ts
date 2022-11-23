import { OvbConfig } from './d';

let config: OvbConfig | null = null;

async function loadConfig(argv?: any): Promise<OvbConfig> {
  if (config !== null) return config;

  const runtimeConfig = useRuntimeConfig()

  const connectionString = runtimeConfig.public.DB_CONNECTION
  if (!connectionString) throw new Error('YOU MUST PROVIDE process.env.DB_CONNECTION')

  config = {
    argv: argv,
    connectionConfig: {
      connectionString: connectionString
    }
  }

  return config
}

export default loadConfig
