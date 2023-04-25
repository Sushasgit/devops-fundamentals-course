import Typography from "@mui/material/Typography";
import { Product } from "~/models/Product";
import CartIcon from "@mui/icons-material/ShoppingCart";
import Add from "@mui/icons-material/Add";
import Remove from "@mui/icons-material/Remove";
import IconButton from "@mui/material/IconButton";
import { useCart, useInvalidateCart, useUpsertCart, useCreateCart } from "~/queries/cart";

type AddProductToCartProps = {
  product: Product;
};

export default function AddProductToCart({ product }: AddProductToCartProps) {
  const { data = [], isFetching } = useCart();

  const shoppingCartId = localStorage.getItem("shopping_cart");

  const { mutate: upsertCart } = useUpsertCart();
  const { mutate: createCart } = useCreateCart();
  const invalidateCart = useInvalidateCart();
  const cartItem = data?.find((i) => i.product.id === product.id);

  const addProduct = () => {
    if (shoppingCartId) {
      upsertCart(
        { product, count: cartItem ? cartItem.count + 1 : 1, shoppingCartId},
        { onSuccess: invalidateCart }
      );
    } else {
      createCart(
        { product, count: cartItem ? cartItem.count + 1 : 1},
        { onSuccess: invalidateCart }
      )
    }
  };

  const removeProduct = () => {
    if (cartItem) {
      upsertCart(
        { ...cartItem, count: cartItem.count - 1 },
        { onSuccess: invalidateCart }
      );
    }
  };

  return cartItem ? (
    <>
      <IconButton disabled={isFetching} onClick={removeProduct} size="large">
        <Remove color={"secondary"} />
      </IconButton>
      <Typography align="center">{cartItem.count}</Typography>
      <IconButton disabled={isFetching} onClick={addProduct} size="large">
        <Add color={"secondary"} />
      </IconButton>
    </>
  ) : (
    <IconButton disabled={isFetching} onClick={addProduct} size="large">
      <CartIcon color={"secondary"} />
    </IconButton>
  );
}
