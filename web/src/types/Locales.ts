export interface Locales {
  main: {
    header: {
      title: string
      tag: string
      description: string
    }
    item: {
      addCart: string
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
      payBank: string
      payCash: string
    }
  }
  currency: string
}
