interface BaseItem {
  name: string
  label: string
  price: number
  [key: string]: unknown
}

interface RawShopItem extends BaseItem {
  category?: string | string[]
  categories?: string | string[]
}

interface ShopItem extends BaseItem {
  categories: string[]
}

interface CartItem extends ShopItem {
  quantity: number
}
