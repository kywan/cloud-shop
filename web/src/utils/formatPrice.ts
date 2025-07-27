import { useConfigStore } from "@/stores/config"

export const formatPrice = (number: number): string => {
  const configStore = useConfigStore()

  if (typeof number !== "number") return String(number)

  const currencySymbol = configStore.locales.currency || "$"
  return `${currencySymbol} ${number.toLocaleString("de-DE")}`
}
