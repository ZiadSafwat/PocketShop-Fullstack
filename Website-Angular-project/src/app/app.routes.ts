// import { Routes } from '@angular/router';

// export const routes: Routes = [];
// import { Routes } from '@angular/router';
// import { authGuard } from './guards/auth.guard';

// export const routes: Routes = [
//   { path: '', loadComponent: () => import('./pages/home/home.component').then(c => c.HomeComponent) },
//   { path: 'login', loadComponent: () => import('./pages/auth/login.component').then(c => c.LoginComponent) },
//   { path: 'register', loadComponent: () => import('./pages/auth/register.component').then(c => c.RegisterComponent) },
//   { path: 'products/:id', loadComponent: () => import('./pages/product-details/product-details.component').then(c => c.ProductDetailsComponent) },
//   { path: 'cart', loadComponent: () => import('./pages/cart/cart.component').then(c => c.CartComponent) },
//   { path: 'wishlist', loadComponent: () => import('./pages/wishlist/wishlist.component').then(c => c.WishlistComponent), canActivate: [authGuard] },
//   { path: 'search', loadComponent: () => import('./pages/search/search.component').then(c => c.SearchComponent) },
//   { path: 'admin/products/new', loadComponent: () => import('./pages/admin/add-product/add-product.component').then(c => c.AddProductComponent), canActivate: [authGuard] },
//   { path: 'admin/products/edit/:id', loadComponent: () => import('./pages/admin/edit-product/edit-product.component').then(c => c.EditProductComponent), canActivate: [authGuard] }
// ];


// import { Routes } from '@angular/router';
// import { adminGuard } from './guards/admin-guard';
// import { authGuard } from './guards/auth-guard';
 

// export const routes: Routes = [
//   { 
//     path: '', 
//     loadComponent: () => import('./pages/home/home.ts').then(c => c.HomeComponent) 
//   },
//   { 
//     path: 'login', 
//     loadComponent: () => import('./pages/auth/login').then(c => c.LoginComponent) 
//   },
//   { 
//     path: 'register', 
//     loadComponent: () => import('./pages/auth/register').then(c => c.RegisterComponent) 
//   },
//   { 
//     path: 'products/:id', 
//     loadComponent: () => import('./pages/product-details/product-details').then(c => c.ProductDetailsComponent) 
//   },
//   { 
//     path: 'cart', 
//     loadComponent: () => import('./pages/cart/cart.component').then(c => c.CartComponent) 
//   },
//   { 
//     path: 'wishlist', 
//     loadComponent: () => import('./pages/wishlist/wishlist.component').then(c => c.WishlistComponent),
//     canActivate: [authGuard] 
//   },
//   { 
//     path: 'search', 
//     loadComponent: () => import('./pages/search/search.component').then(c => c.SearchComponent) 
//   },
//   { 
//     path: 'admin/products/new', 
//     loadComponent: () => import('./pages/admin/add-product/add-product.component').then(c => c.AddProductComponent),
//     canActivate: [adminGuard] 
//   },
//   { 
//     path: 'admin/products/edit/:id', 
//     loadComponent: () => import('./pages/admin/edit-product/edit-product.component').then(c => c.EditProductComponent),
//     canActivate: [adminGuard] 
//   },
//   { path: '**', redirectTo: '' }
// ];


import { Routes } from '@angular/router';
import { adminGuard } from './guards/admin-guard';
import { authGuard } from './guards/auth-guard';

// 1. Static Component Imports for Eager Loading
import { HomeComponent } from './pages/home/home'; 
import { Login } from './pages/auth/login/login';
import { Register } from './pages/auth/register/register';
import { ProductDetails } from './pages/product-details/product-details';
import { Cart } from './pages/cart/cart';
import { Wishlist } from './pages/wishlist/wishlist';
import { Search } from './pages/search/search';
import { AddProduct } from './pages/admin/add-product/add-product';
import { EditProduct } from './pages/admin/edit-product/edit-product';
 
 


export const routes: Routes = [
  { 
    path: '', 
    // Replaced loadComponent with component
    component: HomeComponent 
  },
  { 
    path: 'login', 
    component: Login 
  },
  { 
    path: 'register', 
    component: Register 
  },
  { 
    path: 'products/:id', 
    component: ProductDetails 
  },
  { 
    path: 'cart', 
    component: Cart 
  },
  { 
    path: 'wishlist', 
    component: Wishlist,
    canActivate: [authGuard] 
  },
  { 
    path: 'search', 
    component: Search 
  },
  { 
    path: 'admin/products/new', 
    component: AddProduct,
    canActivate: [adminGuard] 
  },
  { 
    path: 'admin/products/edit/:id', 
    component: EditProduct,
    canActivate: [adminGuard] 
  },
  { path: '**', redirectTo: '' }
];