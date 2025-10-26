import { environment } from '../../environments/environment';
 
export function generateImageUrl(collectionName: string, recordId: string, fileName: string): string {
  return `${environment.apiUrl}files/${collectionName}/${recordId}/${isArrayOfImages(fileName)}`;

}

export function generateRatingStars(rating: number): string {
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

export function getProductImage(product: any): string {
  return product.image && product.image.length > 0
    ? generateImageUrl('product', product.productId || product.id, isArrayOfImages(product.image[0]))
    : environment.noImageUrl;
}
function isArrayOfImages(value: any): string {
  return Array.isArray(value)?value[0]:value;
}
export function getCategoryImage(category: any): string {
  return category.image && category.image.length > 0
    ? generateImageUrl('categories', category.id, category.image[0])
    : environment.noImageUrl;
}