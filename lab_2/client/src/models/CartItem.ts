import { Product } from "~/models/Product";

export type CartItem = {
  product: Product;
  count: number;
  shoppingCartId: string;
};

export type CartItemCreation = {
  product: Product;
  count: number;
};


