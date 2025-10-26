import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { lastValueFrom } from 'rxjs'; 

 import { 
  Category, 
  AvailableColorFilter, 
  AvailableSizeFilter,
  HomeData 
} from '../../../models/product.model'; 
import { ApiService } from '../../../services/api';
import { LanguageService } from '../../../services/language';

 interface HomeResponseWrapper {
    data: HomeData;
 }


@Component({
  selector: 'app-add-product',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './add-product.html',
  styleUrls:['./add-product.scss']
})
export class AddProduct  implements OnInit {
  private apiService = inject(ApiService);
  private router = inject(Router);
  languageService = inject(LanguageService);

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

 
  loading = signal(false);
  submitting = signal(false);
  categories = signal<Category[]>([]);
  selectedFiles: File[] = [];
  imagePreviews = signal<string[]>([]);
 
  availableColors = signal<AvailableColorFilter[]>([]); 
  availableSizes = signal<AvailableSizeFilter[]>([]);   

  translations = {
    add_product: { en: 'Add New Product', ar: 'إضافة منتج جديد' },
    product_info: { en: 'Product Information', ar: 'معلومات المنتج' },
    title_en: { en: 'Product Title (English)', ar: 'عنوان المنتج (الإنجليزية)' },
    title_ar: { en: 'Product Title (Arabic)', ar: 'عنوان المنتج (العربية)' },
    description_en: { en: 'Description (English)', ar: 'الوصف (الإنجليزية)' },
    description_ar: { ar: 'الوصف (العربية)', en: 'Description (Arabic)' },
    price: { en: 'Price', ar: 'السعر' },
    stock: { en: 'Stock Quantity', ar: 'الكمية المتاحة' },
    discount: { en: 'Discount (%)', ar: 'نسبة الخصم (%)' }, 
    category: { en: 'Category', ar: 'الفئة' },
    select_category: { en: 'Select Category', ar: 'اختر الفئة' },
    colors: { en: 'Colors', ar: 'الألوان' },
    sizes: { en: 'Sizes', ar: 'المقاسات' },
    images: { en: 'Product Images', ar: 'صور المنتج' },
    choose_images: { en: 'Choose Images', ar: 'اختر الصور' },
    submit: { en: 'Add Product', ar: 'إضافة المنتج' },
    cancel: { en: 'Cancel', ar: 'إلغاء' },
    loading_data: { en: 'Loading data...', ar: 'جاري تحميل البيانات...' },
    submitting: { en: 'Adding Product...', ar: 'جاري إضافة المنتج...' },
    success: { en: 'Product added successfully!', ar: 'تم إضافة المنتج بنجاح!' },
    error: { en: 'Error adding product', ar: 'خطأ في إضافة المنتج' }
  };

  ngOnInit() {
    this.loadHomeData();
  }
  
   async loadHomeData() {
    this.loading.set(true);
  
    try {
      const response = await lastValueFrom(this.apiService.getHomeData() as any) as HomeResponseWrapper;
  
      if (!response) {
        console.warn('No response received from API');
        return;
      }
  
      const data = response.data;
  
      if (data) {
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

 
async onSubmit(): Promise<void> {
  if (!this.validateForm()) {
    return;
  }

  this.submitting.set(true);

  try {
    // Prepare form data
    const formData = new FormData();
    
    // Add text/number fields
    formData.append('title_en', this.productData.title_en);
    formData.append('title_ar', this.productData.title_ar);
    formData.append('description_en', this.productData.description_en);
    formData.append('description_ar', this.productData.description_ar);
    formData.append('price', this.productData.price.toString());
    formData.append('stock', this.productData.stock.toString());
    formData.append('discountPercentage', this.productData.discountPercentage.toString());
    
    
     
    // 1. RELATION FIELD (Category) - Must be individual appends
    this.productData.category.forEach(id => {
        formData.append('category', id);
    });
    
    // 2. SELECT FIELDS (Colors) - Must be individual appends
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
    
    // Append each element individually using the CORRECT singular field names
    finalColorEn.forEach(value => {
        formData.append('color_en', value);
    });
    finalColorAr.forEach(value => {
        formData.append('color_ar', value);
    });


    // 3. SELECT FIELD (Sizes) - Must be individual appends
    const selectedSizeValues = this.productData.size.filter(size => size.trim() !== '');

    // Append each element individually using the CORRECT singular field name
    selectedSizeValues.forEach(value => {
        formData.append('size', value);
    });
    
    
    // 4. FILE FIELD (Image) - Append only if present
    if (this.selectedFiles.length > 0) {
      this.selectedFiles.forEach(file => {
        formData.append('image', file);
      });
    }

    console.log('Final FormData submitted using individual appends for arrays.');

    // Submit to API
    await lastValueFrom(this.apiService.createProduct(formData));
    
    this.showNotification(this.translations.success[this.languageService.language() as 'en' | 'ar'], 'success');
    
    // Redirect to home after success
    setTimeout(() => {
      this.router.navigate(['/']);
    }, 2000);

  } catch (error) {
    console.error('Error adding product:', error);
     const errorMessage = (error as any)?.response?.data?.category?.message || this.translations.error[this.languageService.language() as 'en' | 'ar'];
    this.showNotification(errorMessage, 'error');
  } finally {
    this.submitting.set(false);
  }
}

 
  // --- validateForm (Standard) ---
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
    
    // Validate discount percentage
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

    if (this.selectedFiles.length === 0) {
      this.showNotification('Please upload at least one product image', 'error');
      return false;
    }

    return true;
  }
  
  // --- showNotification (Standard) ---
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
 