// External Libraries
import { defineStore } from "pinia"
import { ref } from "vue"

// Constants
import { DEV_MODE } from "@/utils/constants"

// Mock Data
import { mockCategories } from "@/mock/categoryMock"
import { mockItems } from "@/mock/itemMock"

export const useShopStore = defineStore("shop", () => {
  const showShop = ref<boolean>(false)

  const selectedCategory = ref<string>("all")
  const categories = ref<Category[]>([])
  const items = ref<ShopItem[]>([])
  const cart = ref<CartItem[]>([])

  if (DEV_MODE) {
    showShop.value = true
    categories.value = mockCategories
    items.value = mockItems
  }

  return {
    showShop,
    selectedCategory,
    categories,
    items,
    cart,
  }
})
