interface ShopItem {
  name: string
  label: string
  category: string
  price: number
}

interface CartItem extends ShopItem {
  quantity: number
}
