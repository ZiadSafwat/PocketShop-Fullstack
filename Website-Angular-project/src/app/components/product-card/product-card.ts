import { Component, input, output, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { Product } from '../../models/product.model';
import { getProductImage, generateRatingStars } from '../../utils/image.utils';
import { CartService } from '../../services/cart';
import { AuthService } from '../../services/auth';
import { ApiService } from '../../services/api';
import { LanguageService } from '../../services/language';

@Component({
  selector: 'app-product-card',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './product-card.html',
  styleUrl: './product-card.scss'
})
export class ProductCard  {
  product = input.required<Product>();
  userWishListId = input.required<string>();
  badge = input<string>('');
  
  wishlistToggled = output<void>();

  private cartService = inject(CartService);
    authService = inject(AuthService);
   apiService = inject(ApiService);
    languageService = inject(LanguageService);
  private router = inject(Router);

  wishlistLoading = signal(false);

  translations = {
    in_stock: { en: 'In Stock', ar: 'متوفر' },
    add_to_cart: { en: 'Add to Cart', ar: 'أضف إلى السلة' },
    details: { en: 'Details', ar: 'التفاصيل' }
  };

  ngOnInit() {
    this.addNotificationStyles();
  }

  getProductImage(product: Product): string {
    return getProductImage(product);
  }

  generateRatingStars(rating: number): string {
    return generateRatingStars(rating);
  }

  hasDiscount(): boolean {
    const product = this.product();
    return !!(product.original_price && product.original_price > product.price);
  }

  getOriginalPrice(): string {
    const product = this.product();
    return product.original_price ? product.original_price.toFixed(2) : '0.00';
  }

  calculateDiscount(): number {
    const product = this.product();
    if (product.original_price && product.original_price > product.price) {
      return Math.round(((product.original_price - product.price) / product.original_price) * 100);
    }
    return 0;
  }

  onCardClick(event: Event): void {
    const target = event.target as HTMLElement;
    if (target.closest('button') || target.closest('.wishlist-btn')) {
      return;
    }
    
    this.navigateToProductDetails();
  }

  onWishlistClick(event: Event): void {
    event.preventDefault();
    event.stopPropagation(); 
    console.log('Wishlist button clicked');
    this.toggleWishlist();
  }

  onAddToCartClick(event: Event): void {
    event.preventDefault();
    event.stopPropagation(); 
    console.log('Add to cart button clicked');
    this.addToCart();
  }

  onDetailsClick(event: Event): void {
    event.preventDefault();
    event.stopPropagation(); 
    console.log('Details button clicked');
    this.navigateToProductDetails();
  }

  private navigateToProductDetails(): void {
    const product = this.product();
    const productId = product.productId || product.id;
    console.log('Navigating to product:', productId);
    this.router.navigate(['/products', productId]);
  }

  addToCart(): void {
    const product = this.product();
    this.cartService.addToCart(product.productId || product.id);
    
    this.showNotification(
      this.languageService.translate('add_to_cart', this.translations) + '!',
      'success'
    );
  }

  async toggleWishlist(): Promise<void> {
    console.log('Toggling wishlist...');
    
    if (!this.authService.authenticated()) {
      this.showNotification(
        this.languageService.language() === 'en' 
          ? 'Please login to add items to wishlist' 
          : 'يرجى تسجيل الدخول لإضافة عناصر إلى المفضلة',
        'warning'
      )
       return;
    }

    this.wishlistLoading.set(true);
    const product = this.product();const userWishListId = this.userWishListId();
    const productId = product.productId || product.id;
    const userId = this.authService.getUserId();
    try {
      if (userWishListId && userWishListId !== 'NotFound') {
        console.log('Updating existing wishlist:', userWishListId);
        await this.apiService.updateWishlist(userWishListId, productId, !product.is_wishlist).toPromise();
      } else if (!product.is_wishlist) {
        console.log('Creating new wishlist item');
        await this.apiService.createWishlist(productId, userId!).toPromise();
      } else {
        console.log('No action needed - product already in wishlist but no wishlist ID');
      }
      
      product.is_wishlist = !product.is_wishlist;
      this.wishlistToggled.emit();
      
 
      const message = product.is_wishlist 
        ? (this.languageService.language() === 'en' ? 'Added to wishlist!' : 'تمت الإضافة إلى المفضلة!')
        : (this.languageService.language() === 'en' ? 'Removed from wishlist!' : 'تمت الإزالة من المفضلة!');
      
      this.showNotification(message, 'success');
      
      console.log('Wishlist toggle successful, new status:', product.is_wishlist);
      
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

  private addNotificationStyles(): void {
    // Check if styles already exist
    if (document.querySelector('style[data-notification-styles]')) {
      return;
    }

    const style = document.createElement('style');
    style.setAttribute('data-notification-styles', 'true');
    style.textContent = `
      @keyframes slideIn {
        from { 
          transform: translateX(100%); 
          opacity: 0; 
        }
        to { 
          transform: translateX(0); 
          opacity: 1; 
        }
      }
      
      @keyframes fadeOut {
        from { 
          opacity: 1; 
        }
        to { 
          opacity: 0; 
        }
      }

      .notification {
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 9999;
        min-width: 300px;
        animation: slideIn 0.3s ease;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        border: none;
        border-radius: 8px;
      }
    `;
    document.head.appendChild(style);
  }
}

const style = document.createElement('style');
style.textContent = `
  @keyframes slideIn {
    from { 
      transform: translateX(100%); 
      opacity: 0; 
    }
    to { 
      transform: translateX(0); 
      opacity: 1; 
    }
  }
  
  @keyframes fadeOut {
    from { 
      opacity: 1; 
    }
    to { 
      opacity: 0; 
    }
  }
`;
document.head.appendChild(style);