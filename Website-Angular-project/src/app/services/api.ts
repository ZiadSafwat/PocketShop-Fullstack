import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { environment } from '../../environments/environment';
import { Observable } from 'rxjs';
import { HomeData, Product, Review, Category, AuthResponse, WishlistItem, User } from '../models/product.model';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private http = inject(HttpClient);
  private apiUrl = environment.apiUrl;

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({
      'Authorization': `Bearer ${token}`,
      'accept': 'application/json'
    });
  }

  private getAuthHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'accept': 'application/json'
    });
  }

  // Authentication
  login(identity: string, password: string): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}collections/users/auth-with-password`, {
      identity,
      password
    });
  }

  register(userData: any): Observable<any> {
    return this.http.post(`${this.apiUrl}collections/users/records`, userData, {
      headers: this.getAuthHeaders()
    });
  }

  // Home data - updated to match PocketBase response structure
  getHomeData(): Observable<{ success: boolean; data: HomeData }> {
    return this.http.get<{ success: boolean; data: HomeData }>(`${this.apiUrl}new/home`, { 
      headers: this.getHeaders() 
    });
  }

  // Products - updated to match PocketBase response structure
  searchProducts(query: string, options: any = {}): Observable<{ success: boolean; data: Product[]; pagination: any }> {
    let params = new HttpParams()
      .set('q', query)
      .set('orderBy', options.orderBy || 'title_en')
      .set('orderDirection', options.orderDirection || 'ASC')
      .set('limit', options.limit?.toString() || '10')
      .set('offset', options.offset?.toString() || '0');

    if (options.categories) params = params.set('category', options.categories);
    if (options.minPrice) params = params.set('minPrice', options.minPrice.toString());
    if (options.maxPrice) params = params.set('maxPrice', options.maxPrice.toString());

    return this.http.get<{ success: boolean; data: Product[]; pagination: any }>(`${this.apiUrl}new/search`, {
      headers: this.getHeaders(),
      params
    });
  }

  getProduct(id: string): Observable<{ success: boolean; data: Product[] }> {
    return this.http.get<{ success: boolean; data: Product[] }>(`${this.apiUrl}new/search?q=${id}`, {
      headers: this.getHeaders()
    });
  }

  // getProductDetails(id: string): Observable<any> {
  //   return this.http.get(`${this.apiUrl}collections/product/records/${id}?expand=category,category.sub_categries,category.sub_categries.sub_categries`, {
  //     headers: this.getHeaders()
  //   });
  // }
 getProductDetails(id: string): Observable<{ success: boolean; data: any }> {
  return this.http.get<{ success: boolean; data: any }>(
    `${this.apiUrl}new/products/${id}`,
    { headers: this.getHeaders() }
  );
}
  createProduct(formData: FormData): Observable<any> {
    return this.http.post(`${this.apiUrl}collections/product/records`, formData, {
      headers: this.getHeaders()
    });
  }

  updateProduct(id: string, formData: FormData): Observable<any> {
    return this.http.patch(`${this.apiUrl}collections/product/records/${id}`, formData, {
      headers: this.getHeaders()
    });
  }

  deleteProduct(id: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}collections/product/records/${id}`, {
      headers: this.getHeaders()
    });
  }

  // Categories
  getCategories(): Observable<any> {
    return this.http.get(`${this.apiUrl}new/home`, {
      headers: this.getHeaders()
    });
  }

  // Wishlist - updated to match PocketBase response structure
  getWishlist(): Observable<{ success: boolean; items: WishlistItem[] }> {
    return this.http.get<{ success: boolean; items: WishlistItem[] }>(`${this.apiUrl}collections/wish_list_items/records?page=1&perPage=30&skipTotal=false&expand=user,products,products.category,products.category.sub_categries`, {
      headers: this.getHeaders()
    });
  }

  updateWishlist(wishListId: string, productId: string, add: boolean): Observable<any> {
    const operation = add ? 'products+' : 'products-';
    return this.http.patch(`${this.apiUrl}collections/wish_list_items/records/${wishListId}`, 
      { [operation]: [productId] },
      { headers: this.getAuthHeaders() }
    );
  }
  removeAllFromWishlist(wishListId: string, productIds: string[]): Observable<any> {
    const operation =   'products-';
    return this.http.patch(`${this.apiUrl}collections/wish_list_items/records/${wishListId}`, 
      { [operation]: productIds },
      { headers: this.getAuthHeaders() }
    );
  }

  createWishlist(productId: string, userId: string): Observable<any> {
    return this.http.post(`${this.apiUrl}collections/wish_list_items/records`,
      { products: [productId], user: userId },
      { headers: this.getAuthHeaders() }
    );
  }

  // Reviews - updated to match PocketBase response structure
  getProductReviews(productId: string): Observable<{ success: boolean; items: Review[] }> {
    return this.http.get<{ success: boolean; items: Review[] }>(`${this.apiUrl}collections/reviews/records?filter=product='${productId}'&expand=user,product`, {
      headers: this.getHeaders()
    });
  }



 
}