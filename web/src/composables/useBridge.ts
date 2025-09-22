// Stores
import { useShopStore } from "@/stores/shop"
import { useConfigStore } from "@/stores/config"

// Utils
import { callback } from "@/utils/callback"

const normalizeItemCategories = (item: RawShopItem): ShopItem => {
  const categories: string[] = []

  const appendCategory = (category: unknown) => {
    if (typeof category === "string") {
      const trimmed = category.trim()
      if (trimmed !== "") {
        categories.push(trimmed)
      }
    }
  }

  const rawCategories = [item.categories, item.category]

  for (const entry of rawCategories) {
    if (Array.isArray(entry)) {
      entry.forEach(appendCategory)
    } else {
      appendCategory(entry)
    }
  }

  const uniqueCategories = Array.from(new Set(categories))

  return {
    ...item,
    categories: uniqueCategories,
  }
}

export const useBridge = () => {
  const shopStore = useShopStore()
  const configStore = useConfigStore()

  const handleMessage = (event: MessageEvent) => {
    const { action, ...data } = event.data

    const actions: Record<string, () => void> = {
      toggleShop: async () => {
        if (data.showShop) {
          shopStore.selectedCategory = "all"
          shopStore.cart = []

          await getLocales()
          await getCategories()
          await getItems()
        }
        shopStore.showShop = data.showShop
      },
    }

    const actionFunction = actions[action]
    if (actionFunction) actionFunction()
  }

  const getCategories = async () => {
    const categories: Category[] = await callback({ action: "getCategories" })
    if (categories) shopStore.categories = categories
  }

  const getItems = async () => {
    const items: RawShopItem[] = await callback({ action: "getItems" })
    if (items) {
      shopStore.items = items.map(normalizeItemCategories)
    }
  }

  const getLocales = async () => {
    const data = await callback({ action: "getLocales" })
    if (data) {
      configStore.imagePath = data.imagePath ?? configStore.imagePath
      configStore.soundVolume = data.soundVolume ?? configStore.soundVolume
      configStore.locales = (data.locales as Locales) ?? configStore.locales
    }
  }

  return { handleMessage }
}
