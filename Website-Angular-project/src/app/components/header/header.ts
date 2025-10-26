import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, Router } from '@angular/router';
import { ThemeService } from '../../services/theme';
import { LanguageService } from '../../services/language';
import { CartService } from '../../services/cart';
import { AuthService } from '../../services/auth';
 

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './header.html',
  styleUrls: ['./header.scss']
})
export class HeaderComponent implements OnInit {
  themeService = inject(ThemeService);
  languageService = inject(LanguageService);
  cartService = inject(CartService);
  authService = inject(AuthService);
  router = inject(Router);

  translations = {
    app_name: { en: 'E-Commerce', ar: 'متجر إلكتروني' },
    home: { en: 'Home', ar: 'الرئيسية' },
    search: { en: 'Search', ar: 'بحث' },
    add_product: { en: 'Add Product', ar: 'إضافة منتج' },
    login: { en: 'Login', ar: 'تسجيل الدخول' },
    logout: { en: 'Logout', ar: 'تسجيل الخروج' },
    view_cart: { en: 'View Cart', ar: 'عرض السلة' },
    view_wishlist: { en: 'View Wishlist', ar: 'عرض المفضلة' },
    user_menu: { en: 'User Menu', ar: 'قائمة المستخدم' },
    profile: { en: 'Profile', ar: 'الملف الشخصي' },
    orders: { en: 'Orders', ar: 'الطلبات' },
    items_in_cart: { en: 'items in cart', ar: 'عناصر في السلة' }
  };

  ngOnInit() {
    // Apply theme to navbar on init
    this.updateNavbarTheme();
  }

  getNavbarClass(): string {
    const theme = this.themeService.theme();
    return theme === 'dark' 
      ? 'navbar-dark bg-dark' 
      : 'navbar-light bg-light';
  }

  updateNavbarTheme(): void {
 
  }

  getUsername(): string {
    const user = this.authService.user();
    return user?.email?.split('@')[0] || 'User';
  }

  logout(): void {
    this.authService.logout();
  }
}