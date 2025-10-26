import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router'; // <-- ADD Router import
import { HomeData, Product, Category, Banner } from '../../models/product.model';
import { getCategoryImage,generateImageUrl } from '../../utils/image.utils';
import { ApiService } from '../../services/api';
import { ThemeService } from '../../services/theme';
import { LanguageService } from '../../services/language';
import { ProductCard } from '../../components/product-card/product-card';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, RouterLink, ProductCard],
  templateUrl: './home.html',
  styleUrls:['./home.scss']
})
export class HomeComponent implements OnInit {
  private apiService = inject(ApiService);
  private router = inject(Router); // <-- Inject the Router
  themeService = inject(ThemeService);
  languageService = inject(LanguageService);

  userWishListId = signal<string | ''>('');
  homeData = signal<HomeData | null>(null);
  banners = signal<any[]>([]);
  categories = signal<Category[]>([]);
  newArrivals = signal<Product[]>([]);
  recommendations = signal<Product[]>([]);
  trendingProducts = signal<Product[]>([]);

  currentBannerIndex = 0;
  currentBanner = signal<any>({});
  loading = signal(true);
  error = signal(false);

  private bannerInterval: any;

  translations = {
    shop_now: { en: 'Shop Now', ar: 'تسوق الآن' },
    categories: { en: 'Categories', ar: 'الفئات' },
    items: { en: 'items', ar: 'منتج' },
    new_arrivals: { en: 'New Arrivals', ar: 'وصل حديثاً' },
    trending: { en: 'Trending Products', ar: 'المنتجات الرائجة' },
    recommendations: { en: 'Recommended For You', ar: 'مقترحة لك' },
    view_all: { en: 'View All', ar: 'عرض الكل' },
    loading: { en: 'Loading...', ar: 'جاري التحميل...' },
    error: { en: 'Error', ar: 'خطأ' },
    load_error: { en: 'Failed to load content. Please try again.', ar: 'فشل تحميل المحتوى. يرجى المحاولة مرة أخرى.' },
    retry: { en: 'Try Again', ar: 'حاول مرة أخرى' }
  };

  ngOnInit() {
    this.loadHomeData();
  }

  ngOnDestroy() {
    if (this.bannerInterval) {
      clearInterval(this.bannerInterval);
    }
  }

  async loadHomeData() {
    this.loading.set(true);
    this.error.set(false);

    try {
      const data = await this.apiService.getHomeData().toPromise();
      
      if (data) {
        this.homeData.set(data.data);
        this.userWishListId.set(data.data.userWishListId);
        // console.log(this.userWishListId());
        
        this.banners.set(data.data.banners);
        this.categories.set(this.flattenCategories(data.data.categories));
        this.newArrivals.set(data.data.new_arrivals);
        this.recommendations.set(data.data.recommendations);
        this.trendingProducts.set(data.data.trending_products);
        
        if (this.banners().length > 0) {
          this.currentBanner.set(this.banners()[0]);
          this.startBannerRotation();
        }
      }
    } catch (error) {
      console.error('Error loading home data:', error);
      this.error.set(true);
    } finally {
      this.loading.set(false);
    }
  }

  getCategoryImage(category: Category): string {
    return getCategoryImage(category);
  }  
  getBannerImage(fileName: string,id:string): string {
    return generateImageUrl('banner',id,fileName );
  }
  
  showBanner(index: number): void {
    this.currentBannerIndex = index;
    this.currentBanner.set(this.banners()[index]);
    this.resetBannerTimer();
  }

  prevBanner(): void {
    this.currentBannerIndex = (this.currentBannerIndex - 1 + this.banners().length) % this.banners().length;
    this.currentBanner.set(this.banners()[this.currentBannerIndex]);
    this.resetBannerTimer();
  }

  nextBanner(): void {
    this.currentBannerIndex = (this.currentBannerIndex + 1) % this.banners().length;
    this.currentBanner.set(this.banners()[this.currentBannerIndex]);
    this.resetBannerTimer();
  }

  startBannerRotation(): void {
    this.bannerInterval = setInterval(() => {
      this.nextBanner();
    }, 5000);
  }

  resetBannerTimer(): void {
    if (this.bannerInterval) {
      clearInterval(this.bannerInterval);
      this.startBannerRotation();
    }
  }

  navigateToBanner(): void {
    if (this.currentBanner().link) {
      window.open(this.currentBanner().link, '_blank');
    }
  }

 
  navigateToCategory(categoryId: string): void {
    this.router.navigate(['/search'], { 
      queryParams: { categoryId: categoryId } 
    });
    console.log('Navigating to search with category:', categoryId);
  }

  private flattenCategories(data: any[]): any[] {
    const result: any[] = [];

    const recurse = (items: any[]) => {
      for (const item of items) {
        result.push(item);
        if (item.children && item.children.length > 0) {
          recurse(item.children);
        }
      }
    };

    recurse(data);
    return result;
  }
}