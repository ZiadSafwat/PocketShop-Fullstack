import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { Category, Product, AvailableColorFilter, AvailableSizeFilter, HomeData } from '../../../models/product.model';
import { ApiService } from '../../../services/api';
import { LanguageService } from '../../../services/language';
import { generateImageUrl } from '../../../utils/image.utils';

interface HomeResponseWrapper {
  data: HomeData;
}

@Component({
  selector: 'app-edit-product',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './edit-product.html',
  styleUrls: ['./edit-product.scss']
})
export class EditProduct implements OnInit {
  private apiService = inject(ApiService);
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  languageService = inject(LanguageService);

  // Product data
  productId = signal<string>('');
  originalProduct = signal<Product | null>(null);
  
  // Form data
  productData = {
    title_en: '',
    title_ar: '',
    description_en: '',
    description_ar: '',
    price: 0,
    stock: 0,
    discountPercentage: 0,
    category: [] as string[],
    color: [] as string[],
    size: [] as string[]
  };

  // UI state
  loading = signal(true);
  submitting = signal(false);
  categories = signal<Category[]>([]);
  selectedFiles: File[] = [];
  imagePreviews = signal<string[]>([]);
  existingImages = signal<string[]>([]);

  // Available filters
  availableColors = signal<AvailableColorFilter[]>([]);
  availableSizes = signal<AvailableSizeFilter[]>([]);

  translations = {
    edit_product: { en: 'Edit Product', ar: 'تعديل المنتج' },
    product_info: { en: 'Product Information', ar: 'معلومات المنتج' },
    title_en: { en: 'Product Title (English)', ar: 'عنوان المنتج (الإنجليزية)' },
    title_ar: { en: 'Product Title (Arabic)', ar: 'عنوان المنتج (العربية)' },
    description_en: { en: 'Description (English)', ar: 'الوصف (الإنجليزية)' },
    description_ar: { en: 'Description (Arabic)', ar: 'الوصف (العربية)' },
    price: { en: 'Price', ar: 'السعر' },
    stock: { en: 'Stock Quantity', ar: 'الكمية المتاحة' },
    discount: { en: 'Discount (%)', ar: 'نسبة الخصم (%)' },
    category: { en: 'Category', ar: 'الفئة' },
    select_category: { en: 'Select Category', ar: 'اختر الفئة' },
    colors: { en: 'Colors', ar: 'الألوان' },
    color_en: { en: 'Color (English)', ar: 'اللون (الإنجليزية)' },
    color_ar: { en: 'Color (Arabic)', ar: 'اللون (العربية)' },
    sizes: { en: 'Sizes', ar: 'المقاسات' },
    size: { en: 'Size', ar: 'المقاس' },
    images: { en: 'Product Images', ar: 'صور المنتج' },
    existing_images: { en: 'Existing Images', ar: 'الصور الحالية' },
    new_images: { en: 'New Images', ar: 'صور جديدة' },
    choose_images: { en: 'Choose Images', ar: 'اختر الصور' },
    update: { en: 'Update Product', ar: 'تحديث المنتج' },
    cancel: { en: 'Cancel', ar: 'إلغاء' },
    loading: { en: 'Loading product...', ar: 'جاري تحميل المنتج...' },
    loading_data: { en: 'Loading data...', ar: 'جاري تحميل البيانات...' },
    submitting: { en: 'Updating Product...', ar: 'جاري تحديث المنتج...' },
    success: { en: 'Product updated successfully!', ar: 'تم تحديث المنتج بنجاح!' },
    error: { en: 'Error updating product', ar: 'خطأ في تحديث المنتج' },
    delete_product: { en: 'Delete Product', ar: 'حذف المنتج' },
    delete_confirm: { en: 'Are you sure you want to delete this product?', ar: 'هل أنت متأكد من حذف هذا المنتج؟' },
    delete_success: { en: 'Product deleted successfully!', ar: 'تم حذف المنتج بنجاح!' }
  };

  async ngOnInit() {
    this.route.params.subscribe(async params => {
      const productId = params['id'];
      if (productId) {
        this.productId.set(productId);
        await this.loadHomeData();
        await this.loadProduct(productId);
      }
    });
  }

  async loadHomeData() {
    try {
      const response = await this.apiService.getHomeData().toPromise() as HomeResponseWrapper;
      
      if (response?.data) {
        const data = response.data;
        
        if (data.categories) {
          this.categories.set(this.flattenCategories(data.categories));
        }
        
        if (data.available_filters?.colors) {
          this.availableColors.set(data.available_filters.colors);
        }
        if (data.available_filters?.sizes) {
          this.availableSizes.set(data.available_filters.sizes);
        }
      }
    } catch (error) {
      console.error('Error loading home data:', error);
    }
  }

  async loadProduct(productId: string): Promise<void> {
    this.loading.set(true);
    try {
      const productData = await this.apiService.getProductDetails(productId).toPromise();
      if (productData?.success && productData.data?.product) {
        const product = productData.data.product;
        this.originalProduct.set(product);
        
        // Populate form data
        this.productData = {
          title_en: product.title_en || '',
          title_ar: product.title_ar || '',
          description_en: product.description_en || '',
          description_ar: product.description_ar || '',
          price: product.price || 0,
          stock: product.stock || 0,
          discountPercentage: product.discountPercentage || 0,
          category: product.category || [],
          color: product.colors_en || [], // Use English colors for selection
          size: product.sizes || []
        };

        // Set existing images
        this.existingImages.set(product.image || []);
      }
    } catch (error) {
      console.error('Error loading product:', error);
      this.showNotification('Error loading product', 'error');
    } finally {
      this.loading.set(false);
    }
  }

  private flattenCategories(data: Category[]): Category[] {
    const result: Category[] = [];

    const recurse = (items: Category[]) => {
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

  onFileSelected(event: any): void {
    const files: FileList = event.target.files;
    if (files.length > 0) {
      this.selectedFiles = Array.from(files);
      
      // Create previews
      const previews: string[] = [];
      for (let i = 0; i < files.length; i++) {
        const reader = new FileReader();
        reader.onload = (e: any) => {
          previews.push(e.target.result);
          if (previews.length === files.length) {
            this.imagePreviews.set(previews);
          }
        };
        reader.readAsDataURL(files[i]);
      }
    }
  }

  removeImage(index: number): void {
    this.selectedFiles.splice(index, 1);
    const previews = this.imagePreviews();
    previews.splice(index, 1);
    this.imagePreviews.set([...previews]);
  }

  removeExistingImage(index: number): void {
    const images = this.existingImages();
    images.splice(index, 1);
    this.existingImages.set([...images]);
  }

  async onSubmit(): Promise<void> {
    if (!this.validateForm()) {
      return;
    }

    this.submitting.set(true);

    try {
      // Prepare form data
      const formData = new FormData();
      
      // Add basic fields
      formData.append('title_en', this.productData.title_en);
      formData.append('title_ar', this.productData.title_ar);
      formData.append('description_en', this.productData.description_en);
      formData.append('description_ar', this.productData.description_ar);
      formData.append('price', this.productData.price.toString());
      formData.append('stock', this.productData.stock.toString());
      formData.append('discountPercentage', this.productData.discountPercentage.toString());
      
      // Add category - append each individually
      this.productData.category.forEach(id => {
        formData.append('category', id);
      });
      
      // Process colors - get both English and Arabic values
      const selectedColorValues = this.productData.color.filter(color => color.trim() !== '');
      
      const finalColorEn: string[] = [];
      const finalColorAr: string[] = [];

      selectedColorValues.forEach(selectedValue => {
        const colorObject = this.availableColors().find(
          c => c.value_en === selectedValue || c.value_ar === selectedValue
        );
        if (colorObject) {
          finalColorEn.push(colorObject.value_en); 
          finalColorAr.push(colorObject.value_ar);
        }
      });
      
      // Append each color individually using the CORRECT singular field names
      finalColorEn.forEach(value => {
        formData.append('color_en', value);
      });
      finalColorAr.forEach(value => {
        formData.append('color_ar', value);
      });

      // Process sizes - append each individually
      const selectedSizeValues = this.productData.size.filter(size => size.trim() !== '');
      selectedSizeValues.forEach(value => {
        formData.append('size', value);
      });
      
      // Add new images
      this.selectedFiles.forEach(file => {
        formData.append('image', file);
      });

      // Add existing images that weren't removed
      this.existingImages().forEach(imageUrl => {
        formData.append('existingImages', imageUrl);
      });

      // Update product
      await this.apiService.updateProduct(this.productId(), formData).toPromise();
      
      this.showNotification(this.translations.success[this.languageService.language() as 'en' | 'ar'], 'success');
      
      // Redirect to product details after success
      setTimeout(() => {
        this.router.navigate(['/products', this.productId()]);
      }, 2000);

    } catch (error) {
      console.error('Error updating product:', error);
      this.showNotification(this.translations.error[this.languageService.language() as 'en' | 'ar'], 'error');
    } finally {
      this.submitting.set(false);
    }
  }

  getImageUrl(imageName: string): string {
    const product = this.originalProduct();
    if (!product) return '';
    
    return generateImageUrl('product', product.productId || product.id, imageName);
  }

  async deleteProduct(): Promise<void> {
    const message = this.languageService.language() === 'en' 
      ? this.translations.delete_confirm.en
      : this.translations.delete_confirm.ar;
    
    if (!confirm(message)) {
      return;
    }

    try {
      await this.apiService.deleteProduct(this.productId()).toPromise();
      
      this.showNotification(this.translations.delete_success[this.languageService.language() as 'en' | 'ar'], 'success');
      
      // Redirect to home after deletion
      setTimeout(() => {
        this.router.navigate(['/']);
      }, 2000);

    } catch (error) {
      console.error('Error deleting product:', error);
      this.showNotification('Error deleting product', 'error');
    }
  }

  private validateForm(): boolean {
    if (!this.productData.title_en.trim() || !this.productData.title_ar.trim()) {
      this.showNotification('Product title is required in both languages', 'error');
      return false;
    }

    if (this.productData.price <= 0) {
      this.showNotification('Price must be greater than 0', 'error');
      return false;
    }

    if (this.productData.stock < 0) {
      this.showNotification('Stock quantity cannot be negative', 'error');
      return false;
    }

    if (this.productData.discountPercentage < 0 || this.productData.discountPercentage > 100) {
      this.showNotification('Discount percentage must be between 0 and 100', 'error');
      return false;
    }

    if (this.productData.category.length === 0) {
      this.showNotification('Please select at least one category', 'error');
      return false;
    }

    if (this.productData.color.length === 0) {
      this.showNotification('Please select at least one color', 'error');
      return false;
    }

    if (this.productData.size.length === 0) {
      this.showNotification('Please select at least one size', 'error');
      return false;
    }

    if (this.existingImages().length === 0 && this.selectedFiles.length === 0) {
      this.showNotification('Please upload at least one product image', 'error');
      return false;
    }

    return true;
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
}