export interface Product {
  id: string;
  productId: string;
  title_en: string;
  title_ar: string;
  description_en: string;
  description_ar: string;
  price: number;
  original_price?: number;
  stock: number;
  image: string[];
  category: string[];
  category_name_ar?: string;
  category_name_en?: string;
  rating: number;
  review_count: number;
  is_wishlist: boolean;
  userWishListId?: string;
  userId?: string;
  collectionName?: string;
  created?: string;
  discountPercentage?: number;
  colors_en?: string[];
  colors_ar?: string[];
  sizes?: string[];
  recommendation_score?: number;
  orderCount?: number;
}

export interface CartItem {
  id: string;
  quantity: number;
  product?: Product;
}

export interface Category {
  id: string;
  title: {
    en: string;
    ar: string;
  };
  image: string[];
  totalItemsNumber: number;
  children?: Category[];
  expanded?: boolean;
  level?: number;
}

export interface Banner {
  id: string;
  title: string;
  subtitle: string;
  image: string;
  link: string;
}

export interface Review {
  id: string;
  rating: number;
  comment: string;
  created: string;
  expand?: {
    user?: {
      id: string;
      name: string;
      avatar: string;
    };
    product?: Product;
  };
}

export interface HomeData {
  banners: Banner[];
  categories: Category[];
  new_arrivals: Product[];
  recommendations: Product[];
  trending_products: Product[];
  userWishListId: string;
  recentSearches?: any[];
  available_filters?: AvailableFilters;
  // available_filters?: {
  //   colors: string[];
  //   sizes: string[];
  // };
}

export interface User {
  id: string;
  email: string;
  role: string;
  avatar: string;
  name: string;
}

export interface AuthResponse {
  token: string;
  record: User;
}

export interface WishlistItem {
  id: string;
  products: string[];
  user: string;
  expand?: {
    products?: Product[];
  };
}
 export interface ProductDetailsResponse {
  success: boolean;
  data: {
    userId: string;
    userWishListId: string;
    product: Product;
    recommended_products: Product[];
    top_reviews: Review[];
  };
}


 
export interface AvailableColorFilter {
  value_en: string; // The color name in English (e.g., "Brown")
  value_ar: string; // The color name in Arabic (e.g., "بني")
  hex_code?: string; // Optional: The hex code for color swatch display
}
 
export interface AvailableSizeFilter {
  value: string; // The size string (e.g., "S", "M", "40")
}
 
export interface AvailableFilters {
  colors: AvailableColorFilter[];
  sizes: AvailableSizeFilter[];
}