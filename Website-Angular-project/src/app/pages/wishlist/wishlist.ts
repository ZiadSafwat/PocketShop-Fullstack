import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';

import { Product, WishlistItem } from '../../models/product.model';
import { ProductCard } from '../../components/product-card/product-card';
import { ApiService } from '../../services/api';
import { CartService } from '../../services/cart';
import { AuthService } from '../../services/auth';
import { LanguageService } from '../../services/language';

@Component({
  selector: 'app-wishlist',
  standalone: true,
  imports: [CommonModule, RouterLink, ProductCard],
  templateUrl: './wishlist.html',
  styleUrl: './wishlist.scss',
})
export class Wishlist implements OnInit {
  private apiService = inject(ApiService);
  private cartService = inject(CartService);
  private authService = inject(AuthService);
  languageService = inject(LanguageService);

  wishlistItems = signal<Product[]>([]);
  loading = signal(true);
  userWishListId: string = '';

  translations = {
    my_wishlist: { en: 'My Wishlist', ar: 'قائمة المفضلة' },
    empty_wishlist: { en: 'Your Wishlist is Empty', ar: 'قائمة المفضلة فارغة' },
    empty_wishlist_message: {
      en: 'Add some products to your wishlist!',
      ar: 'أضف بعض المنتجات إلى قائمة المفضلة!',
    },
    browse_products: { en: 'Browse Products', ar: 'تصفح المنتجات' },
    wishlist_items: { en: 'Wishlist Items', ar: 'عناصر المفضلة' },
    wishlist_saved: {
      en: 'Products you have saved for later',
      ar: 'المنتجات التي حفظتها لوقت لاحق',
    },
    clear_wishlist: { en: 'Clear Wishlist', ar: 'تفريغ المفضلة' },
    loading_wishlist: { en: 'Loading your wishlist...', ar: 'جاري تحميل قائمة المفضلة...' },
  };

  async ngOnInit() {
    await this.loadWishlist();
  }

  async loadWishlist(): Promise<void> {
    this.loading.set(true);

    try {
      const wishlistData = await this.apiService.getWishlist().toPromise();

      if (wishlistData?.items && wishlistData.items.length > 0) {
        const wishlistItem = wishlistData.items[0];
        const products = wishlistItem.expand?.products || [];

        const wishlistProducts = products.map((product) => ({
          ...product,
          is_wishlist: true,
          userWishListId: wishlistItem.id,
        }));

        this.wishlistItems.set(wishlistProducts);
      } else {
        this.wishlistItems.set([]);
      }
    } catch (error) {
      console.error('Error loading wishlist:', error);
      this.wishlistItems.set([]);
    } finally {
      this.loading.set(false);
    }
  }

  onWishlistToggled(): void {
    this.loadWishlist();
  }

  async clearWishlist(): Promise<void> {
    if (
      !confirm(
        this.languageService.language() === 'en'
          ? 'Are you sure you want to clear your entire wishlist?'
          : 'هل أنت متأكد من أنك تريد تفريغ قائمة المفضلة بالكامل؟'
      )
    ) {
      return;
    }

    this.loading.set(true);

    try {
      const wishlistData = await this.apiService.getWishlist().toPromise();

      if (wishlistData?.items && wishlistData.items.length > 0) {
        this.userWishListId = wishlistData.items[0].id;

        let ids: string[] = [];

        for (const product of this.wishlistItems()) {
          ids.push(product.id);
        }

        if (ids.length > 0) {
          await this.apiService.removeAllFromWishlist(this.userWishListId, ids).toPromise();
        }

        this.wishlistItems.set([]);
      }
    } catch (error) {
      console.error('Error clearing wishlist:', error);
    } finally {
      this.loading.set(false);
    }
  }
}
