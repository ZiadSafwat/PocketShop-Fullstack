import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router,RouterLink } from '@angular/router';
import { Product } from '../../models/product.model';
import { ApiService } from '../../services/api';
import { LanguageService } from '../../services/language';
import { ProductCard } from '../../components/product-card/product-card';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-search',
  standalone: true,
  imports: [CommonModule,RouterLink, FormsModule, ProductCard],
  templateUrl: './search.html',
  styleUrl: './search.scss',
})
export class Search implements OnInit {
  private apiService = inject(ApiService);
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  languageService = inject(LanguageService);

  searchQuery = '';
  searchResults = signal<Product[]>([]);
  categories = signal<any[]>([]);
  loading = signal(false);
  viewMode = signal<'grid' | 'list'>('grid');
  userWishListId: string = '';

   
  sortBy = 'title_en';
  minPrice = '';
  maxPrice = '';
  selectedCategory = '';  

  private searchTimeout: any;

  translations = {
    search_results: { en: 'Search Products', ar: 'بحث في المنتجات' },
    search_placeholder: { en: 'Search for products...', ar: 'ابحث عن منتجات...' },
    search: { en: 'Search', ar: 'بحث' },
    filters: { en: 'Filters', ar: 'الفلاتر' },
    sort_by: { en: 'Sort By', ar: 'ترتيب حسب' },
    name_asc: { en: 'Name (A-Z)', ar: 'الاسم (أ-ي)' },
    price_low_high: { en: 'Price: Low to High', ar: 'السعر: من الأقل للأعلى' },
    price_high_low: { en: 'Price: High to Low', ar: 'السعر: من الأعلى للأقل' },
    rating: { en: 'Highest Rated', ar: 'الأعلى تقييماً' },
    newest: { en: 'Newest', ar: 'الأحدث' },
    price_range: { en: 'Price Range', ar: 'نطاق السعر' },
    category: { en: 'Category', ar: 'الفئة' },
    all_categories: { en: 'All Categories', ar: 'جميع الفئات' },
    clear_filters: { en: 'Clear Filters', ar: 'مسح الفلاتر' },
    showing: { en: 'Showing', ar: 'عرض' },
    products: { en: 'products', ar: 'منتج' },
    for: { en: 'for', ar: 'لـ' },
    in_stock: { en: 'In Stock', ar: 'متوفر' },
    add_to_cart: { en: 'Add to Cart', ar: 'أضف إلى السلة' },
    details: { en: 'Details', ar: 'التفاصيل' },
    no_results: { en: 'No Results Found', ar: 'لم يتم العثور على نتائج' },
    no_results_message: { en: 'No products found for', ar: 'لم يتم العثور على منتجات لـ' },
    clear_search: { en: 'Clear Search', ar: 'مسح البحث' },
    search_initial: { en: 'Start Searching', ar: 'ابدأ البحث' },
    search_initial_message: { en: 'Enter a search term to find products', ar: 'أدخل مصطلح البحث للعثور على المنتجات' }
  };

  ngOnInit() {
    this.loadCategories();
     // Check for query parameters for initial load/navigation
    this.route.queryParams.subscribe(params => {
      let shouldPerformSearch = false;
      
      if (params['q']) {
        this.searchQuery = params['q'];
        shouldPerformSearch = true;
      }
      
      // Check for category ID parameter
      if (params['categoryId']) {
        this.selectedCategory = params['categoryId'];
        shouldPerformSearch = true;
      }

      if (shouldPerformSearch) {
        // Run search immediately when navigating via URL with parameters
        this.performSearch(); 
      }
    });
  }
 
  onSearch(event: Event): void {
    event.preventDefault();
    this.performSearch();
  }

  onSearchInput(): void {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout);
    }
    
    this.searchTimeout = setTimeout(() => {
       if (this.searchQuery.length >= 2 || (this.searchQuery.length === 0 && this.selectedCategory)) {
        this.performSearch();
      } else if (this.searchQuery.length === 0 && !this.selectedCategory) {
        this.searchResults.set([]);
      }
    }, 500);
  }

  async performSearch(): Promise<void> {
     if (!this.searchQuery.trim() && !this.selectedCategory) {
      this.searchResults.set([]);
      this.updateUrlParams(); 
      return;
    }

    this.loading.set(true);

    try {
      const searchOptions: any = {};

     
      if (this.sortBy === 'price_asc') {
        searchOptions.orderBy = 'price';
        searchOptions.orderDirection = 'ASC';
      } else if (this.sortBy === 'price_desc') {
        searchOptions.orderBy = 'price';
        searchOptions.orderDirection = 'DESC';
      } else if (this.sortBy === 'rating') {
        searchOptions.orderBy = 'rating';
        searchOptions.orderDirection = 'DESC';
      } else if (this.sortBy === 'newest') {
        searchOptions.orderBy = 'created';
        searchOptions.orderDirection = 'DESC';
      }

      
      if (this.minPrice) searchOptions.minPrice = this.minPrice;
      if (this.maxPrice) searchOptions.maxPrice = this.maxPrice;
      
      
      if (this.selectedCategory) searchOptions.categories = this.selectedCategory;

      const query = this.searchQuery.trim() || ''; 
      const results = await this.apiService.searchProducts(query, searchOptions).toPromise();
      this.searchResults.set(results?.data || []);

       
      this.updateUrlParams();

    } catch (error) {
      console.error('Search error:', error);
      this.searchResults.set([]);
    } finally {
      this.loading.set(false);
    }
  }

  applyFilters(): void {
    this.performSearch();
  }

  clearFilters(): void {
    this.sortBy = 'title_en';
    this.minPrice = '';
    this.maxPrice = '';
    this.selectedCategory = ''; 
    
  
    this.performSearch();
  }

  clearSearch(): void {
    this.searchQuery = '';
    this.searchResults.set([]);
    this.selectedCategory = '';  
    this.updateUrlParams();
  }
  
  private updateUrlParams(): void {
    this.router.navigate([], {
      queryParams: { 
        q: this.searchQuery || null, 
        categoryId: this.selectedCategory || null 
      },
      queryParamsHandling: 'merge'
    });
  }

  async loadCategories(): Promise<void> {
    try {
      const homeData = await this.apiService.getHomeData().toPromise();
      if (homeData?.data.categories) {
        this.userWishListId =homeData.data.userWishListId;
        this.categories.set(this.flattenCategories(homeData.data.categories));
      }
    } catch (error) {
      console.error('Error loading categories:', error);
    }
  } 

  getProductImage(product: Product): string {
    return product.image && product.image.length > 0
      ? `${environment.apiUrl}files/product/${product.productId || product.id}/${product.image[0]}`
      : `${environment.apiUrl}files/d307x3zqff91y9v/mmf3off8f3r9frx/box_2071537_640_iA7kzWD6ej.png?token=`;
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

  addToCart(productId: string): void {
    // todo implement this
    console.log('Add to cart:', productId);
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