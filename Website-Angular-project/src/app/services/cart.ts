import { Injectable, signal, computed } from '@angular/core';
import { CartItem, Product } from '../models/product.model';

@Injectable({
  providedIn: 'root'
})
export class CartService {
  private cart = signal<CartItem[]>(this.loadCartFromStorage());

  cartItems = this.cart.asReadonly();
  cartCount = computed(() => this.cart().reduce((total, item) => total + item.quantity, 0));
  cartTotal = computed(() => this.cart().reduce((total, item) => total + (item.product?.price || 0) * item.quantity, 0));

  private loadCartFromStorage(): CartItem[] {
    if (typeof window !== 'undefined') {
      const cartData = localStorage.getItem('cart');
      return cartData ? JSON.parse(cartData) : [];
    }
    return [];
  }

  private saveCartToStorage(): void {
    if (typeof window !== 'undefined') {
      localStorage.setItem('cart', JSON.stringify(this.cart()));
    }
  }

  addToCart(productId: string): void {
    const currentCart = this.cart();
    const existingItem = currentCart.find(item => item.id === productId);

    if (existingItem) {
      existingItem.quantity += 1;
    } else {
      currentCart.push({
        id: productId,
        quantity: 1
      });
    }

    this.cart.set([...currentCart]);
    this.saveCartToStorage();
    this.showNotification('Product added to cart!', 'success');
  }

  updateQuantity(productId: string, quantity: number): void {
    if (quantity < 1) {
      this.removeFromCart(productId);
      return;
    }

    const currentCart = this.cart();
    const item = currentCart.find(item => item.id === productId);
    
    if (item) {
      item.quantity = quantity;
      this.cart.set([...currentCart]);
      this.saveCartToStorage();
    }
  }

  removeFromCart(productId: string): void {
    const currentCart = this.cart().filter(item => item.id !== productId);
    this.cart.set(currentCart);
    this.saveCartToStorage();
    this.showNotification('Product removed from cart!', 'warning');
  }

  clearCart(): void {
    this.cart.set([]);
    this.saveCartToStorage();
  }

  getCartCount(): number {
    return this.cartCount();
  }

  getTotalPrice(): number {
    return this.cartTotal();
  }

  setProductDetails(productId: string, product: Product): void {
    const currentCart = this.cart();
    const item = currentCart.find(item => item.id === productId);
    
    if (item) {
      item.product = product;
      this.cart.set([...currentCart]);
      this.saveCartToStorage();
    }
  }

  private showNotification(message: string, type: 'success' | 'error' | 'warning' = 'success'): void {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification alert alert-${type === 'error' ? 'danger' : type} position-fixed`;
    notification.style.cssText = `
      top: 80px;
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

    // Add to DOM
    document.body.appendChild(notification);

    // Remove after 3 seconds
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
}