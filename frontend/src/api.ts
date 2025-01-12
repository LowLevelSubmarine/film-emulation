import {Config} from "./data"

export async function getConfig() {
  const response = await fetch('http://localhost:8080', {method: 'GET'})
  const config: Config = await response.json()
  console.log(config)
  return config
}

export async function resetConfig() {
  const response = await fetch('http://localhost:8080/reset', {method: 'GET'})
  const config: Config = await response.json()
  console.log(config)
  return config
}

export async function postConfig(config: Config) {
  try {
    const response = await fetch('http://localhost:8080', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(config),
    })

    if (!response.ok) {
      console.error('Failed to post config:', response.status, response.statusText)
    } else {
      console.log('Configuration updated successfully')
    }
  } catch (error) {
    console.error('Error posting config:', error)
  }
}