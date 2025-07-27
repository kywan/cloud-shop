import { DEV_MODE } from "@/utils/constants"

export const callback = async (data: Callback): Promise<any | null> => {
  if (DEV_MODE) return true

  try {
    // @ts-expect-error: GetParentResourceName
    const response = await fetch(`https://${GetParentResourceName()}/shop:callback`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    })

    if (!response.ok) {
      const error = await response.text()
      console.error(`[shop:${data.action}] Callback failed: ${response.status} ${response.statusText}`, error)
      return null
    }

    return await response.json()
  } catch (err) {
    console.error(`[shop:${data.action}] Callback error:`, err)
    return null
  }
}
