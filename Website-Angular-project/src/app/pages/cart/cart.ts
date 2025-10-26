import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { CartItem, Product } from '../../models/product.model';
import { getProductImage } from '../../utils/image.utils';
import { CartService } from '../../services/cart';
import { ApiService } from '../../services/api';
import { LanguageService } from '../../services/language';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './cart.html',
  styleUrl: './cart.scss'
})
export class Cart implements OnInit {
  private cartService = inject(CartService);
  private apiService = inject(ApiService);
  languageService = inject(LanguageService);

  cartItems = signal<CartItem[]>([]);
  loading = signal(true);

 
  subtotal = computed(() => this.cartService.getTotalPrice());
  tax = computed(() => this.subtotal() * 0.1); // 10% tax
  total = computed(() => this.subtotal() + this.tax());

  translations = {
    shopping_cart: { en: 'Shopping Cart', ar: 'سلة التسوق' },
    empty_cart: { en: 'Your Cart is Empty', ar: 'سلة التسوق فارغة' },
    empty_cart_message: { en: 'Add some products to your cart!', ar: 'أضف بعض المنتجات إلى سلة التسوق!' },
    start_shopping: { en: 'Start Shopping', ar: 'ابدأ التسوق' },
    cart_items: { en: 'Cart Items', ar: 'عناصر السلة' },
    continue_shopping: { en: 'Continue Shopping', ar: 'مواصلة التسوق' },
    clear_cart: { en: 'Clear Cart', ar: 'تفريغ السلة' },
    order_summary: { en: 'Order Summary', ar: 'ملخص الطلب' },
    subtotal: { en: 'Subtotal', ar: 'المجموع الفرعي' },
    shipping: { en: 'Shipping', ar: 'الشحن' },
    free: { en: 'FREE', ar: 'مجاني' },
    tax: { en: 'Tax', ar: 'الضريبة' },
    total: { en: 'Total', ar: 'المجموع الكلي' },
    proceed_checkout: { en: 'Proceed to Checkout', ar: 'إتمام الشراء' },
    secure_checkout: { en: 'Secure & Encrypted Checkout', ar: 'شراء آمن ومشفر' },
    promo_code: { en: 'Promo Code', ar: 'كود الخصم' },
    enter_promo: { en: 'Enter promo code', ar: 'أدخل كود الخصم' },
    apply: { en: 'Apply', ar: 'تطبيق' }
  };

  async ngOnInit() {
    await this.loadCartItems();
  }

  async loadCartItems(): Promise<void> {
    this.loading.set(true);
    
    try {
      const items = this.cartService.cartItems();
      
  
      for (const item of items) {
        if (!item.product) {
          try {
            const productData = await this.apiService.getProduct(item.id).toPromise();
            if (productData?.data && productData.data.length > 0) {
              this.cartService.setProductDetails(item.id, productData.data[0]);
            }
          } catch (error) {
            console.error(`Error loading product ${item.id}:`, error);
          }
        }
      }
      
      this.cartItems.set([...items]);
    } catch (error) {
      console.error('Error loading cart items:', error);
    } finally {
      this.loading.set(false);
    }
  }

  getProductImage(product?: Product): string {
    return getProductImage(product || {} as Product);
  }

  getProductTitle(product?: Product): string {
    if (!product) return 'Loading...';
    return this.languageService.language() === 'en' ? product.title_en : product.title_ar;
  }

  getProductCategory(product?: Product): string {
    if (!product) return '';
    return product.category_name_ar || 'Uncategorized';
  }

  generateRatingStars(rating: number): string {
    const fullStars = Math.floor(rating);
    const halfStar = rating % 1 >= 0.5;
    let stars = '';

    for (let i = 1; i <= 5; i++) {
      if (i <= fullStars) {
        stars += '<i class="fas fa-star"></i>';
      } else if (i === fullStars + 1 && halfStar) {
        stars += '<i class="fas fa-star-half-alt"></i>';
      } else {
        stars += '<i class="far fa-star"></i>';
      }
    }

    return stars;
  }

  updateQuantity(productId: string, quantity: number): void {
    this.cartService.updateQuantity(productId, quantity);
    this.cartItems.set([...this.cartService.cartItems()]);
  }

  validateQuantity(item: CartItem): void {
    if (item.quantity < 1) {
      item.quantity = 1;
      this.cartService.updateQuantity(item.id, 1);
      this.cartItems.set([...this.cartService.cartItems()]);
    }
  }

  removeFromCart(productId: string): void {
    this.cartService.removeFromCart(productId);
    this.cartItems.set([...this.cartService.cartItems()]);
  }

  clearCart(): void {
    if (confirm(this.languageService.language() === 'en' 
        ? 'Are you sure you want to clear your cart?' 
        : 'هل أنت متأكد من أنك تريد تفريغ سلة التسوق؟')) {
      this.cartService.clearCart();
      this.cartItems.set([]);
    }
  }

  checkout(): void {
     alert(this.languageService.language() === 'en' 
      ? `Thank you for your order! Total: $${this.total().toFixed(2)}` 
      : `شكراً لطلبك! المجموع: $${this.total().toFixed(2)}`);
    
    this.cartService.clearCart();
    this.cartItems.set([]);
  }
}