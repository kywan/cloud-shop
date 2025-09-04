import { useConfigStore } from "@/stores/config"

export const formatPrice = (number: number): string => {
  const configStore = useConfigStore()

  if (typeof number !== "number") return String(number)

  const numberLocale = number.toLocaleString("de-DE")
  const currencySymbol = configStore.locales.currency.symbol || "$"
  const currencyPosition = configStore.locales.currency.position || "before"

  if (currencyPosition === "before") {
    return `${currencySymbol} ${numberLocale}`
  } else {
    return `${numberLocale} ${currencySymbol}`
  }
}
