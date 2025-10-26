import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
 
import { Product, Review } from '../../models/product.model';
import { generateImageUrl, generateRatingStars } from '../../utils/image.utils';
import { ProductCard } from '../../components/product-card/product-card';
import { ApiService } from '../../services/api';
import { CartService } from '../../services/cart';
import { AuthService } from '../../services/auth';
import { LanguageService } from '../../services/language';

@Component({
  selector: 'app-product-details',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, ProductCard],
  templateUrl: './product-details.html',
  styleUrls: ['./product-details.scss']
})
export class ProductDetails implements OnInit {
  private apiService = inject(ApiService);
  private cartService = inject(CartService);
  authService = inject(AuthService);
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  languageService = inject(LanguageService);

  product = signal<Product | null>(null);
  reviews = signal<Review[]>([]);
  relatedProducts = signal<Product[]>([]);
  loading = signal(true);
  wishlistLoading = signal(false);

  currentImageIndex = 0;
  currentImage = signal('');
  quantity = signal(1);
  userWishListId = signal<string>('');

  translations = {
    loading: { en: 'Loading...', ar: 'جاري التحميل...' },
    home: { en: 'Home', ar: 'الرئيسية' },
    reviews: { en: 'reviews', ar: 'تقييم' },
    description: { en: 'Description', ar: 'الوصف' },
    availability: { en: 'Availability', ar: 'التوفر' },
    in_stock: { en: 'In Stock', ar: 'متوفر' },
    out_of_stock: { en: 'Out of Stock', ar: 'غير متوفر' },
    sku: { en: 'SKU', ar: 'الرمز' },
    stock: { en: 'Stock', ar: 'المخزون' },
    available: { en: 'available', ar: 'متوفر' },
    quantity: { en: 'Quantity', ar: 'الكمية' },
    add_to_cart: { en: 'Add to Cart', ar: 'أضف إلى السلة' },
    out_of_stock_message: { en: 'This product is currently out of stock', ar: 'هذا المنتج غير متوفر حالياً' },
    remove_wishlist: { en: 'Remove from Wishlist', ar: 'إزالة من المفضلة' },
    add_wishlist: { en: 'Add to Wishlist', ar: 'إضافة إلى المفضلة' },
    back_products: { en: 'Back to Products', ar: 'العودة للمنتجات' },
    edit_product: { en: 'Edit Product', ar: 'تعديل المنتج' },
    customer_reviews: { en: 'Customer Reviews', ar: 'تقييمات العملاء' },
    anonymous: { en: 'Anonymous', ar: 'مجهول' },
    no_reviews: { en: 'No Reviews Yet', ar: 'لا توجد تقييمات بعد' },
    no_reviews_message: { en: 'Be the first to review this product!', ar: 'كن أول من يقيم هذا المنتج!' },
    related_products: { en: 'Related Products', ar: 'منتجات ذات صلة' },
    product_not_found: { en: 'Product Not Found', ar: 'المنتج غير موجود' },
    product_not_found_message: { en: 'The product you are looking for does not exist.', ar: 'المنتج الذي تبحث عنه غير موجود.' },
    back_home: { en: 'Back to Home', ar: 'العودة للرئيسية' },
    colors: { en: 'Colors', ar: 'الألوان' },
  sizes: { en: 'Sizes', ar: 'المقاسات' },
  };

  async ngOnInit() {
    this.route.params.subscribe(params => {
      const productId = params['id'];
      if (productId) {
        this.loadProductDetails(productId); // Use the correct method name
      }
    });
  }

   async loadProductDetails(productId: string): Promise<void> {
    this.loading.set(true);
    
    try {
       const productDetails = await this.apiService.getProductDetails(productId).toPromise();
      
      if (productDetails?.success && productDetails.data) {
        const productData = productDetails.data;
        
         this.product.set(productData.product);
        this.userWishListId.set(productData.userWishListId);
        
         if (productData.product.image && productData.product.image.length > 0) {
          this.currentImage.set(this.getImageUrl(productData.product.image[0]));
        }
        
         this.reviews.set(productData.top_reviews || []);
        this.relatedProducts.set(productData.recommended_products || []);
        
      } else {
        this.product.set(null);
      }
    } catch (error) {
      console.error('Error loading product details:', error);
       await this.loadProductBasicInfo(productId);
    } finally {
      this.loading.set(false);
    }
  }

   async loadProductBasicInfo(productId: string): Promise<void> {
    try {
      const productData = await this.apiService.getProduct(productId).toPromise();
      
      if (productData?.data && productData.data.length > 0) {
        const product = productData.data[0];
        this.product.set(product);
        
         if (product.image && product.image.length > 0) {
          this.currentImage.set(this.getImageUrl(product.image[0]));
        }
        
         await this.loadReviews(productId);
        
         await this.loadRelatedProducts(product);
      } else {
        this.product.set(null);
      }
    } catch (error) {
      console.error('Error loading basic product info:', error);
      this.product.set(null);
    }
  }

  async loadReviews(productId: string): Promise<void> {
    try {
      const reviewsData = await this.apiService.getProductReviews(productId).toPromise();
      this.reviews.set(reviewsData?.items || []);
    } catch (error) {
      console.error('Error loading reviews:', error);
      this.reviews.set([]);
    }
  }

  async loadRelatedProducts(product: Product): Promise<void> {
    try {
 
      if (product.category && product.category.length > 0) {
        const relatedData = await this.apiService.searchProducts('', {
          categories: product.category[0],
          limit: 4
        }).toPromise();
        

        const filtered = (relatedData?.data || []).filter(p => 
          p.productId !== product.productId && p.id !== product.id
        );
        this.relatedProducts.set(filtered.slice(0, 4));
      }
    } catch (error) {
      console.error('Error loading related products:', error);
      this.relatedProducts.set([]);
    }
  }

  getImageUrl(imageName: string): string {
    const product = this.product();
    if (!product) return '';
    
    return generateImageUrl('product', product.productId || product.id, imageName);
  }

  changeImage(index: number): void {
    const product = this.product();
    if (!product || !product.image[index]) return;
    
    this.currentImageIndex = index;
    this.currentImage.set(this.getImageUrl(product.image[index]));
  }

  generateRatingStars(rating: number): string {
    return generateRatingStars(rating);
  }

  hasDiscount(): boolean {
    const product = this.product();
    return !!(product && product.original_price && product.original_price > product.price);
  }

  getOriginalPrice(): string {
    const product = this.product();
    return product?.original_price ? product.original_price.toFixed(2) : '0.00';
  }

  calculateDiscount(): number {
    const product = this.product();
    if (!product || !product.original_price || product.original_price <= product.price) {
      return 0;
    }
    
    return Math.round(((product.original_price - product.price) / product.original_price) * 100);
  }

  getProductTitle(): string {
    const product = this.product();
    if (!product) return '';
    return this.languageService.language() === 'en' ? product.title_en : product.title_ar;
  }

  getProductDescription(): string {
    const product = this.product();
    if (!product) return '';
    return this.languageService.language() === 'en' ? product.description_en : product.description_ar;
  }

  getCategoryName(): string {
    const product = this.product();
    return (this.languageService.language() === 'en'? product?.category_name_en :product?.category_name_ar) || 'Uncategorized';
  }

  increaseQuantity(): void {
    const product = this.product();
    if (product && this.quantity() < product.stock) {
      this.quantity.set(this.quantity() + 1);
    }
  }

  decreaseQuantity(): void {
    if (this.quantity() > 1) {
      this.quantity.set(this.quantity() - 1);
    }
  }

  onQuantityChange(event: any): void {
    const value = parseInt(event.target.value, 10);
    const product = this.product();
    
    if (!isNaN(value) && value >= 1) {
      if (product && value > product.stock) {
        this.quantity.set(product.stock);
      } else {
        this.quantity.set(value);
      }
    } else {
      this.quantity.set(1);
    }
  }

  addToCart(): void {
    const product = this.product();
    if (!product) return;
    
    for (let i = 0; i < this.quantity(); i++) {
      this.cartService.addToCart(product.productId || product.id);
    }
    
 
    this.showNotification(
      this.languageService.language() === 'en' 
        ? `Added ${this.quantity()} item(s) to cart!` 
        : `تم إضافة ${this.quantity()} عنصر(عناصر) إلى السلة!`,
      'success'
    );
    
    this.quantity.set(1);
  }

  async toggleWishlist(): Promise<void> {
    if (!this.authService.authenticated()) {
      this.showNotification(
        this.languageService.language() === 'en' 
          ? 'Please login to add items to wishlist' 
          : 'يرجى تسجيل الدخول لإضافة عناصر إلى المفضلة',
        'warning'
      );
      return;
    }

    const product = this.product();
    if (!product) return;

    this.wishlistLoading.set(true);
    const productId = product.productId || product.id;
    const userId = this.authService.getUserId();
    const userWishListId = this.userWishListId() || product.userWishListId;

    console.log('Wishlist toggle data:', {
      productId,
      userId,
      userWishListId,
      currentStatus: product.is_wishlist
    });

    try {
      if (userWishListId && userWishListId !== 'NotFound') {
        await this.apiService.updateWishlist(userWishListId, productId, !product.is_wishlist).toPromise();
      } else if (!product.is_wishlist) {
        await this.apiService.createWishlist(productId, userId!).toPromise();
      }
      
 
      product.is_wishlist = !product.is_wishlist;
      this.product.set({...product});
      
 
      const message = product.is_wishlist 
        ? (this.languageService.language() === 'en' ? 'Added to wishlist!' : 'تمت الإضافة إلى المفضلة!')
        : (this.languageService.language() === 'en' ? 'Removed from wishlist!' : 'تمت الإزالة من المفضلة!');
      
      this.showNotification(message, 'success');
      
    } catch (error) {
      console.error('Wishlist toggle error:', error);
      this.showNotification(
        this.languageService.language() === 'en' 
          ? 'Failed to update wishlist' 
          : 'فشل تحديث المفضلة',
        'error'
      );
    } finally {
      this.wishlistLoading.set(false);
    }
  }

  formatDate(dateString: string): string {
    return new Date(dateString).toLocaleDateString(this.languageService.language(), {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  }

  private showNotification(message: string, type: 'success' | 'error' | 'warning' = 'success'): void {
    const notification = document.createElement('div');
    notification.className = `notification alert alert-${type === 'error' ? 'danger' : type} position-fixed`;
    notification.style.cssText = `
      top: 20px;
      right: 20px;
      z-index: 9999;
      min-width: 300px;
      animation: slideIn 0.3s ease;
    `;
    notification.innerHTML = `
      <div class="d-flex align-items-center">
        <i class="fas ${
          type === 'success' ? 'fa-check-circle' : 
          type === 'error' ? 'fa-exclamation-circle' : 
          'fa-exclamation-triangle'
        } me-2"></i>
        <span>${message}</span>
      </div>
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
      if (notification.parentNode) {
        notification.style.animation = 'fadeOut 0.3s ease';
        setTimeout(() => {
          if (notification.parentNode) {
            document.body.removeChild(notification);
          }
        }, 300);
      }
    }, 3000);
  }



 

 hasColors(): boolean {
  const product = this.product();
  if (!product) return false;
  
  const colors = this.languageService.language() === 'en' 
    ? product.colors_en 
    : product.colors_ar;
  
  return !!colors && Array.isArray(colors) && colors.length > 0;
}

 getColorsDisplay(): string {
  const product = this.product();
  if (!product) return '';
  
  const colors = this.languageService.language() === 'en' 
    ? product.colors_en 
    : product.colors_ar;
  
  if (!colors || !Array.isArray(colors)) return '';
  
  return colors.join(', ');
}

 hasSizes(): boolean {
  const product = this.product();
  return !!(product?.sizes && Array.isArray(product.sizes) && product.sizes.length > 0);
}

 getSizesDisplay(): string {
  const product = this.product();
  if (!product?.sizes || !Array.isArray(product.sizes)) return '';
  
  return product.sizes.join(', ');
}
}