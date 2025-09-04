// Stores
import { useShopStore } from "@/stores/shop"
import { useConfigStore } from "@/stores/config"

// Utils
import { callback } from "@/utils/callback"

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
    const items: ShopItem[] = await callback({ action: "getItems" })
    if (items) shopStore.items = items
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
