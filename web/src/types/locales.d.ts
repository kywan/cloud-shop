interface Locales {
  currency: {
    symbol: string
    position: "before" | "after"
  }

  main: {
    header: {
      title: string
      tag: string
      description: string
    }
    item: {
      add_cart: string
    }
  }

  cart: {
    header: {
      title: string
      tag: string
      description: string
    }
    payment: {
      title: string
      pay_bank: string
      pay_cash: string
    }
  }
}
