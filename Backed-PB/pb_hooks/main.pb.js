routerAdd(
  "GET",
  "/api/new/home",
  (c) => {
    // 1. Authentication
    const authRecord = c.get("authRecord");
    if (!authRecord) {
      throw new ApiError(401, "Unauthorized");
    }
    const userId = authRecord.id;

    // 2. Query Definitions with reviews and ratings
    const recommendationsQuery = `
    WITH user_wishlist AS (
      SELECT json_each.value AS product_id
      FROM wish_list_items, json_each(wish_list_items.products)
      WHERE wish_list_items.user = '${userId}'
    ),
    popular_products AS (
      SELECT 
        p.id,
        COUNT(DISTINCT o.id) * 0.6 AS order_score,
        COALESCE(AVG(r.rating), 3) * 0.4 AS review_score
      FROM product p
      LEFT JOIN (
          orders o
          JOIN json_each(o.products)
          ON 1=1
      ) ON o.status = 'success' AND json_each.value = p.id
      LEFT JOIN reviews r ON r.product = p.id
      GROUP BY p.id
    )
    SELECT
      p.id as productId,
      p.title_ar,
      p.title_en,
      p.price,
      p.image,
      p.description_ar,
      p.description_en,
      p.stock,
      p.discountPercentage,
      p.color_en,
      p.color_ar,
      p.size,
      json_extract(p.category, '$[0]') AS category_id, 
      cat.title_ar AS category_name_ar,
      cat.title_en AS category_name_en,
      (
        COALESCE((SELECT 1 FROM user_wishlist w WHERE w.product_id = p.id), 0) * 0.5 +
        COALESCE(pp.order_score, 0) * 0.3 +
        COALESCE(pp.review_score, 0) * 0.2
      ) AS recommendation_score,
      COALESCE(pp.review_score / 0.4, 0) AS avg_rating,
      (SELECT COUNT(*) FROM reviews r WHERE r.product = p.id) AS review_count,
      EXISTS (
        SELECT 1 
        FROM wish_list_items w, json_each(w.products) j
        WHERE w.user = '${userId}' AND j.value = p.id
      ) AS is_wishlist
    FROM product p
    LEFT JOIN popular_products pp ON p.id = pp.id
    LEFT JOIN categories cat ON cat.id = json_extract(p.category, '$[0]')
    ORDER BY recommendation_score DESC
    LIMIT 10;
    `;

    const trendingProductsQuery = `
    WITH order_counts AS (
      SELECT 
        json_each.value AS product_id,
        COUNT(*) AS order_count
      FROM orders, json_each(orders.products)
      WHERE orders.status = 'success'
      GROUP BY product_id
    )
    SELECT 
      p.id as productId,
      p.title_ar,
      p.title_en,
      p.price,
      p.image,
      p.description_ar,
      p.description_en,
      p.stock,
      p.discountPercentage,
      p.color_en,
      p.color_ar,
      p.size,
      json_extract(p.category, '$[0]') AS category_id,
      cat.title_ar AS category_name_ar,
      cat.title_en AS category_name_en,
      oc.order_count as orderCount,
      COALESCE((SELECT AVG(rating) FROM reviews r WHERE r.product = p.id), 0) AS avg_rating,
      (SELECT COUNT(*) FROM reviews r WHERE r.product = p.id) AS review_count,
      EXISTS (
        SELECT 1 
        FROM wish_list_items w, json_each(w.products) j
        WHERE w.user = '${userId}' AND j.value = p.id
      ) AS is_wishlist
    FROM product p
    JOIN order_counts oc ON p.id = oc.product_id
    LEFT JOIN categories cat ON cat.id = json_extract(p.category, '$[0]')
    ORDER BY oc.order_count DESC
    LIMIT 10
    `;

    const newArrivalsQuery = `
    SELECT 
      p.id as productId,
      p.title_ar,
      p.title_en,
      p.price,
      p.image,
      p.description_ar,
      p.description_en,
      p.stock,
      p.discountPercentage,
      p.color_en,
      p.color_ar,
      p.size,
      json_extract(p.category, '$[0]') AS category_id,
      cat.title_ar AS category_name_ar,
      cat.title_en AS category_name_en,
      COALESCE((SELECT AVG(rating) FROM reviews r WHERE r.product = p.id), 0) AS avg_rating,
      (SELECT COUNT(*) FROM reviews r WHERE r.product = p.id) AS review_count,
      EXISTS (
        SELECT 1 
        FROM wish_list_items w, json_each(w.products) j
        WHERE w.user = '${userId}' AND j.value = p.id
      ) AS is_wishlist
    FROM product p
    LEFT JOIN categories cat ON cat.id = json_extract(p.category, '$[0]')
    ORDER BY p.created DESC 
    LIMIT 10
    `;
    
    const bannerQuery = `
    SELECT 
      id,
      title,
      subtitle,
      image,
      link
    FROM banner   
    `;

    // Query to get all available colors and sizes
    const availableFiltersQuery = `
    SELECT 
      (
        SELECT GROUP_CONCAT(DISTINCT value)
        FROM (
          SELECT json_each.value as value
          FROM product, json_each(product.color_en)
          WHERE value IS NOT NULL AND value != ''
          UNION
          SELECT json_each.value as value
          FROM product, json_each(product.color_ar)
          WHERE value IS NOT NULL AND value != ''
        )
      ) as all_colors,
      (
        SELECT GROUP_CONCAT(DISTINCT value)
        FROM product, json_each(product.size)
        WHERE value IS NOT NULL AND value != ''
      ) as all_sizes
    `;

    // 3. Result Models with correct types
    const recommendations = arrayOf(
      new DynamicModel({
        productId: "",
        title_ar: "",
        title_en: "",
        price: 0.0,
        image: "",
        description_ar: "",
        description_en: "",
        stock: 0,
        discountPercentage: 0,
        color_en: "",
        color_ar: "",
        size: "",
        category_id: "",
        category_name_ar: "",
        category_name_en: "",
        recommendation_score: "0.0",
        avg_rating: "0.0",
        review_count: 0,
        is_wishlist: false,
      })
    );

    const trendingProducts = arrayOf(
      new DynamicModel({
        productId: "",
        title_ar: "",
        title_en: "",
        price: 0.0,
        image: "",
        description_ar: "",
        description_en: "",
        stock: 0,
        discountPercentage: 0,
        color_en: "",
        color_ar: "",
        size: "",
        orderCount: 0,
        category_id: "",
        category_name_ar: "",
        category_name_en: "",
        avg_rating: "0.0",
        review_count: 0,
        is_wishlist: false,
      })
    );

    const newArrivals = arrayOf(
      new DynamicModel({
        productId: "",
        title_ar: "",
        title_en: "",
        price: 0.0,
        image: "",
        description_ar: "",
        description_en: "",
        stock: 0,
        discountPercentage: 0,
        color_en: "",
        color_ar: "",
        size: "",
        category_id: "",
        category_name_ar: "",
        category_name_en: "",
        avg_rating: "0.0",
        review_count: 0,
        is_wishlist: false,
      })
    );

    const availableFilters = arrayOf(
      new DynamicModel({
        all_colors: "",
        all_sizes: "",
      })
    );

    const userQueryData = arrayOf(
      new DynamicModel({
        search_query: "",
      })
    );
    
    const banners = arrayOf(
      new DynamicModel({
        id: "",
        title: "",
        subtitle: "",
        image: "",
        link: "",
      })
    );
    
    // Query all categories
    const categories = arrayOf(
      new DynamicModel({
        id: "",
        title_ar: "",
        title_en: "",
        image: "",
        sub_categries: ""
      })
    );
    
    // Step 2: Load products with category relations
    const products = arrayOf(
      new DynamicModel({ category: "" })
    );

    // Helper function to handle image field
    const handleImageField = (image) => {
      if (!image) return [];
      try {
        // Try parsing as JSON array
        const parsed = JSON.parse(image);
        return Array.isArray(parsed) ? parsed : [image];
      } catch {
        // If not JSON, treat as single filename
        return [image];
      }
    };

    // Helper function to handle JSON array fields
    const handleJsonArrayField = (field) => {
      if (!field) return [];
      try {
        const parsed = JSON.parse(field);
        return Array.isArray(parsed) ? parsed : [field];
      } catch (e) {
        return [field];
      }
    };

    // 4. Execute Queries with Error Handling
    try {
      $app.db().newQuery(recommendationsQuery).all(recommendations);
    } catch (e) {
      console.error("Recommendations query failed:", e);
      throw new ApiError(
        500,
        "Failed to generate personalized recommendations"
      );
    }

    try {
      $app.db().newQuery(newArrivalsQuery).all(newArrivals);
    } catch (e) {
      console.error("New arrivals query failed:", e);
      newArrivals.length = 0;
    }

    try {
      $app.db().newQuery(trendingProductsQuery).all(trendingProducts);
    } catch (e) {
      console.error("Trending products query failed:", e);
      trendingProducts.length = 0;
    }

    try {
      $app.db().newQuery(availableFiltersQuery).all(availableFilters);
    } catch (e) {
      console.error("Available filters query failed:", e);
      availableFilters.length = 0;
    }

    try {
      $app
        .db()
        .select("search_query", "user")
        .from("user_search")
        .andWhere($dbx.like("user", authRecord.id))
        .limit(5)
        .orderBy("created ASC")
        .all(userQueryData);
    } catch (e) {
      console.error("User query failed:", e);
    }

    try {
      $app.db().newQuery(bannerQuery).all(banners);
      console.log(`Fetched ${banners.length} banners`);
    } catch (e) {
      console.error("Banner query failed:", e.message || e);
      if (e.originalError) {
        console.error("Original database error:", e.originalError);
      }
      throw new ApiError(500, "Failed to fetch banners");
    }

    try {
      $app.db().newQuery(`
        SELECT id, title_ar, title_en, image, sub_categries
        FROM categories
      `).all(categories);
    } catch (e) {
      console.error("Categories query failed:", e);
      throw new ApiError(500, "Failed to fetch categories");
    }
  
    try {
      $app.db().newQuery(`SELECT category FROM product`).all(products);
    } catch (e) {
      console.error("Product query failed:", e);
      // Fail-safe: if product query fails, category counts default to 0
    }

    // Step 3: Build category → product count map
    const categoryCountMap = new Map();

    for (const p of products) {
      try {
        if (p.category) {
          const categoryIds = JSON.parse(p.category);
          if (Array.isArray(categoryIds)) {
            for (const id of categoryIds) {
              if (typeof id === "string" && id.trim() !== "") {
                categoryCountMap.set(id, (categoryCountMap.get(id) || 0) + 1);
              }
            }
          }
        }
      } catch {
        // Ignore parse errors
      }
    }

    // Step 4: Image parser
    const parseImage2 = (image) => {
      if (!image) return [];
      try {
        const parsed = JSON.parse(image);
        return Array.isArray(parsed) ? parsed : [parsed.toString()];
      } catch {
        return [image.toString()];
      }
    };

    // Step 5: Prepare category nodes
    const categoryMap = new Map();
    const childToParentMap = new Map();
    const allChildIds = new Set();

    for (const raw of categories) {
      let subList = [];
      try {
        if (raw.sub_categries) {
          subList = JSON.parse(raw.sub_categries);
          if (!Array.isArray(subList)) subList = [];
        }
      } catch {
        subList = [];
      }

      const node = {
        id: raw.id,
        title: {
          ar: raw.title_ar,
          en: raw.title_en
        },
        image: parseImage2(raw.image),
        totalItemsNumber: categoryCountMap.get(raw.id) || 0,
        children: [],
        expanded: false,
        level: 0
      };

      categoryMap.set(raw.id, node);

      for (const childId of subList) {
        if (typeof childId === "string" && childId.trim() !== "") {
          childToParentMap.set(childId, raw.id);
          allChildIds.add(childId);
        }
      }
    }

    // Step 6: Build tree hierarchy
    const rootNodes = [];

    for (const [id, node] of categoryMap.entries()) {
      const parentId = childToParentMap.get(id);
      if (parentId && categoryMap.has(parentId)) {
        const parent = categoryMap.get(parentId);
        node.level = parent.level + 1;
        parent.children.push(node);
      } else if (!allChildIds.has(id)) {
        rootNodes.push(node); // Only root-level if not a child elsewhere
      }
    }

    // Step 7: Optional sorting of children by title
    const sortTree = (node) => {
      node.children.sort((a, b) => a.title.en.localeCompare(b.title.en));
      node.children.forEach(sortTree);
    };

    rootNodes.forEach(sortTree);

    //search user wishlist
    const userWishListId = arrayOf(
      new DynamicModel({
        id: "",
      })
    );
    try {
      $app
        .db()
        .select("id", "user")
        .from("wish_list_items")
        .andWhere($dbx.like("user", authRecord.id))
        .limit(1)
        .orderBy("created ASC")
        .all(userWishListId);
    } catch (e) {
      console.error("wish_list_items query failed:", e);
    }

    // Process available filters
    let availableColors = [];
    let availableSizes = [];
    
    if (availableFilters.length > 0) {
      const filters = availableFilters[0];
      
      // Process colors
      if (filters.all_colors) {
        availableColors = filters.all_colors.split(',').filter(color => color && color.trim() !== '');
      }
      
      // Process sizes
      if (filters.all_sizes) {
        availableSizes = filters.all_sizes.split(',').filter(size => size && size.trim() !== '');
      }
    }

    // 5. Return response with proper mapping
    return c.json(200, {
      success: true,
      data: {
        userWishListId: userWishListId.length > 0 ? userWishListId[0].id : null,
        recentSearches: userQueryData,
        recommendations: recommendations.map((r) => ({
          productId: r.productId,
          title_ar: r.title_ar,
          title_en: r.title_en,
          price: r.price,
          image: handleImageField(r.image),
          description_ar: r.description_ar,
          description_en: r.description_en,
          stock: r.stock,
          discountPercentage: r.discountPercentage,
          colors_en: handleJsonArrayField(r.color_en),
          colors_ar: handleJsonArrayField(r.color_ar),
          sizes: handleJsonArrayField(r.size),
          category: r.category_id,
          category_name_ar: r.category_name_ar,
          category_name_en: r.category_name_en,
          recommendation_score: parseFloat(r.recommendation_score),
          rating: parseFloat(r.avg_rating),
          review_count: parseInt(r.review_count),
          is_wishlist: r.is_wishlist,
        })),
        new_arrivals: newArrivals.map((n) => ({
          productId: n.productId,
          title_ar: n.title_ar,
          title_en: n.title_en,
          price: n.price,
          image: handleImageField(n.image),
          description_ar: n.description_ar,
          description_en: n.description_en,
          stock: n.stock,
          discountPercentage: n.discountPercentage,
          colors_en: handleJsonArrayField(n.color_en),
          colors_ar: handleJsonArrayField(n.color_ar),
          sizes: handleJsonArrayField(n.size),
          category: n.category_id,
          category_name_ar: n.category_name_ar,
          category_name_en: n.category_name_en,
          rating: parseFloat(n.avg_rating),
          review_count: parseInt(n.review_count),
          is_wishlist: n.is_wishlist,
        })),
        trending_products: trendingProducts.map((t) => ({
          productId: t.productId,
          title_ar: t.title_ar,
          title_en: t.title_en,
          price: t.price,
          image: handleImageField(t.image),
          description_ar: t.description_ar,
          description_en: t.description_en,
          stock: t.stock,
          discountPercentage: t.discountPercentage,
          colors_en: handleJsonArrayField(t.color_en),
          colors_ar: handleJsonArrayField(t.color_ar),
          sizes: handleJsonArrayField(t.size),
          category: t.category_id,
          category_name_ar: t.category_name_ar,
          category_name_en: t.category_name_en,
          orderCount: t.orderCount,
          rating: parseFloat(t.avg_rating),
          review_count: parseInt(t.review_count),
          is_wishlist: t.is_wishlist,
        })),
        banners: banners,
        categories: rootNodes,
        available_filters: {
          colors: availableColors,
          sizes: availableSizes
        }
      },
    });
  },
  $apis.requireRecordAuth("users")
);
routerAdd(
  "GET",
  "/api/new/search",
  (c) => {
    // 1. Authentication
    const authRecord = c.get("authRecord");
    if (!authRecord) {
      console.log("Authentication failed: User not authorized.");
      throw new ApiError(401, "Unauthorized");
    }
    console.log(`User authenticated: ${authRecord.id}`);

    // 2. Get Query Parameters
    const queryParams = c.queryParam;
    const searchQuery = queryParams("q") || "";
    let categoryFilter = queryParams("category") || "";
    let colorFilter = queryParams("colors") || "";
    let sizeFilter = queryParams("sizes") || "";
    
    const parseNumberParam = (param, defaultValue = null) => {
      const value = queryParams(param);
      if (value === null || value === undefined) return defaultValue;
      const num = parseFloat(value);
      return isNaN(num) ? defaultValue : num;
    };

    const minPrice = parseNumberParam("minPrice");
    const maxPrice = parseNumberParam("maxPrice");
    const minRating = parseNumberParam("minRating");
    const orderBy = queryParams("orderBy") || "title_en";
    const orderDirection = queryParams("orderDirection") || "ASC";
    const limit = parseInt(queryParams("limit")) || 10;
    const offset = parseInt(queryParams("offset")) || 0;

    // Save search query if not empty
    if (searchQuery) {
      try {
        const userSearchCollection = $app
          .dao()
          .findCollectionByNameOrId("user_search");
        if (userSearchCollection) {
          const newSavedSearch = new Record(userSearchCollection);
          newSavedSearch.set("search_query", searchQuery);
          newSavedSearch.set("user", authRecord.id);
          $app.dao().save(newSavedSearch);
          console.log("Search saved successfully");
        }
      } catch (error) {
        console.error("Save failed:", error);
      }
    }

    // Handle category IDs
    let categoryIds = [];
    if (categoryFilter) {
      categoryIds = categoryFilter
        .split(",")
        .map((id) => String(id).trim())
        .filter((id) => id);
    }

    // Handle color filters
    let colors = [];
    if (colorFilter) {
      colors = colorFilter
        .split(",")
        .map((color) => String(color).trim())
        .filter((color) => color);
    }

    // Handle size filters
    let sizes = [];
    if (sizeFilter) {
      sizes = sizeFilter
        .split(",")
        .map((size) => String(size).trim())
        .filter((size) => size);
    }

    // 3. Construct SQL Query with category names
    let sqlQuery = `
      SELECT
        p.id as productId,
        p.title_ar,
        p.title_en,
        p.price,
        p.image,
        p.description_ar,
        p.description_en,
        p.stock,
        p.discountPercentage,
        p.color_en,
        p.color_ar,
        p.size,
        p.category,
        -- Get category names using JSON functions
        (
          SELECT json_group_array(cat.title_ar)
          FROM categories cat
          WHERE cat.id IN (SELECT value FROM json_each(p.category))
        ) AS category_names_ar,
        (
          SELECT json_group_array(cat.title_en)
          FROM categories cat
          WHERE cat.id IN (SELECT value FROM json_each(p.category))
        ) AS category_names_en,
        COALESCE((SELECT AVG(rating) FROM reviews r WHERE r.product = p.id), 0) AS avg_rating,
        (SELECT COUNT(*) FROM reviews r WHERE r.product = p.id) AS review_count,
        EXISTS (
          SELECT 1 
          FROM wish_list_items w, json_each(w.products) j
          WHERE w.user = {:userId} AND j.value = p.id
        ) AS is_wishlist
      FROM product p
      WHERE 1=1
    `;

    // Count query for pagination
    let countQuery = `
      SELECT COUNT(DISTINCT p.id) as total
      FROM product p
      WHERE 1=1
    `;

    const queryArgs = { userId: authRecord.id };
    const countArgs = {};

    // Search condition
    if (searchQuery) {
      sqlQuery += `
        AND (
          p.id LIKE {:searchQuery} OR
          p.title_en LIKE {:searchQuery} OR
          p.title_ar LIKE {:searchQuery} OR
          p.description_en LIKE {:searchQuery} OR
          p.description_ar LIKE {:searchQuery}
        )
      `;
      countQuery += `
        AND (
          p.id LIKE {:searchQuery} OR
          p.title_en LIKE {:searchQuery} OR
          p.title_ar LIKE {:searchQuery} OR
          p.description_en LIKE {:searchQuery} OR
          p.description_ar LIKE {:searchQuery}
        )
      `;
      queryArgs.searchQuery = `%${searchQuery}%`;
      countArgs.searchQuery = `%${searchQuery}%`;
    }

    // Category condition
    if (categoryIds.length > 0) {
      const categoryPlaceholders = categoryIds
        .map((_, index) => `{:cat${index}}`)
        .join(", ");

      sqlQuery += `
        AND EXISTS (
          SELECT 1 FROM json_each(p.category) AS j
          WHERE j.value IN (${categoryPlaceholders})
        )
      `;
      countQuery += `
        AND EXISTS (
          SELECT 1 FROM json_each(p.category) AS j
          WHERE j.value IN (${categoryPlaceholders})
        )
      `;

      categoryIds.forEach((id, index) => {
        queryArgs[`cat${index}`] = id;
        countArgs[`cat${index}`] = id;
      });
    }

    // Color condition
    if (colors.length > 0) {
      const colorPlaceholders = colors
        .map((_, index) => `{:color${index}}`)
        .join(", ");

      sqlQuery += `
        AND EXISTS (
          SELECT 1 FROM json_each(p.color_en) AS j
          WHERE j.value IN (${colorPlaceholders})
        )
      `;
      countQuery += `
        AND EXISTS (
          SELECT 1 FROM json_each(p.color_en) AS j
          WHERE j.value IN (${colorPlaceholders})
        )
      `;

      colors.forEach((color, index) => {
        queryArgs[`color${index}`] = color;
        countArgs[`color${index}`] = color;
      });
    }

    // Size condition
    if (sizes.length > 0) {
      const sizePlaceholders = sizes
        .map((_, index) => `{:size${index}}`)
        .join(", ");

      sqlQuery += `
        AND EXISTS (
          SELECT 1 FROM json_each(p.size) AS j
          WHERE j.value IN (${sizePlaceholders})
        )
      `;
      countQuery += `
        AND EXISTS (
          SELECT 1 FROM json_each(p.size) AS j
          WHERE j.value IN (${sizePlaceholders})
        )
      `;

      sizes.forEach((size, index) => {
        queryArgs[`size${index}`] = size;
        countArgs[`size${index}`] = size;
      });
    }

    // Price filtering
    if (minPrice !== null) {
      sqlQuery += ` AND p.price >= {:minPrice}`;
      countQuery += ` AND p.price >= {:minPrice}`;
      queryArgs.minPrice = minPrice;
      countArgs.minPrice = minPrice;
    }

    if (maxPrice !== null) {
      sqlQuery += ` AND p.price <= {:maxPrice}`;
      countQuery += ` AND p.price <= {:maxPrice}`;
      queryArgs.maxPrice = maxPrice;
      countArgs.maxPrice = maxPrice;
    }

    // Rating filtering
    if (minRating !== null) {
      sqlQuery += ` AND (
        SELECT AVG(rating) FROM reviews r WHERE r.product = p.id
      ) >= {:minRating}`;
      countQuery += ` AND (
        SELECT AVG(rating) FROM reviews r WHERE r.product = p.id
      ) >= {:minRating}`;
      queryArgs.minRating = minRating;
      countArgs.minRating = minRating;
    }

    // Add grouping
    sqlQuery += ` GROUP BY p.id `;

    // Add ordering
    const allowedOrderBy = [
      "title_en",
      "title_ar",
      "price",
      "stock",
      "created",
      "avg_rating",
    ];
    const actualOrderBy = allowedOrderBy.includes(orderBy)
      ? orderBy
      : "title_en";
    const actualOrderDirection =
      orderDirection.toUpperCase() === "DESC" ? "DESC" : "ASC";

    sqlQuery += ` ORDER BY ${
      actualOrderBy === "avg_rating" ? "avg_rating" : "p." + actualOrderBy
    } ${actualOrderDirection}`;

    // Add pagination
    sqlQuery += ` LIMIT {:limit} OFFSET {:offset}`;
    queryArgs.limit = limit;
    queryArgs.offset = offset;

    console.log("SQL Query:", sqlQuery);
    console.log("Query Args:", JSON.stringify(queryArgs));

    // 4. Result Model with category names
    const searchResults = arrayOf(
      new DynamicModel({
        productId: "",
        title_ar: "",
        title_en: "",
        price: 0,
        image: [],
        description_ar: "",
        description_en: "",
        stock: 0,
        discountPercentage: 0,
        color_en: "",
        color_ar: "",
        size: "",
        category: "",
        category_names_ar: "",
        category_names_en: "",
        avg_rating: "0",
        review_count: 0,
        is_wishlist: false,
      })
    );

    // Helper function to handle image field
    const handleImageField = (image) => {
      if (!image) return [];
      try {
        const parsed = JSON.parse(image);
        return Array.isArray(parsed) ? parsed : [image];
      } catch (e) {
        return [image];
      }
    };
    
    // Helper function to handle JSON array fields
    const handleJsonArrayField = (field) => {
      if (!field) return [];
      try {
        // If it's already an array, return it
        if (Array.isArray(field)) return field;
        
        // If it's a string, try to parse it as JSON
        if (typeof field === 'string') {
          const parsed = JSON.parse(field);
          return Array.isArray(parsed) ? parsed : [parsed];
        }
        
        // If it's something else, wrap it in an array
        return [field];
      } catch (e) {
        console.error('Error parsing JSON array:', e);
        return [field];
      }
    };

    //search user wishlist
    const userWishListId = arrayOf(
      new DynamicModel({
        id: "",
      })
    );
    try {
      $app
        .db()
        .select("id", "user")
        .from("wish_list_items")
        .andWhere($dbx.like("user", authRecord.id))
        .limit(1)
        .orderBy("created ASC")
        .all(userWishListId);
    } catch (e) {
      console.error("wish_list_items query failed:", e);
    }

    // 5. Execute Count Query for pagination
    let totalItems = 0;
    try {
      const countResults = arrayOf(new DynamicModel({ total: 0 }));
      $app.db().newQuery(countQuery).bind(countArgs).all(countResults);
      totalItems = countResults[0]?.total || 0;
    } catch (e) {
      console.error("Count query failed:", e);
    }

    // 6. Execute Main Query
    try {
      $app.db().newQuery(sqlQuery).bind(queryArgs).all(searchResults);
    } catch (e) {
      console.error("Search query failed:", e);
      throw new ApiError(500, "Failed to search products");
    }

    // 7. Return response with category names
    const mappedResults = searchResults.map((p) => ({
      userId: authRecord.id,
      userWishListId: userWishListId.length > 0 ? userWishListId[0].id : 'NotFound',
      productId: p.productId,
      title_ar: p.title_ar,
      title_en: p.title_en,
      price: parseFloat(p.price),
      image: handleImageField(p.image),
      description_ar: p.description_ar,
      description_en: p.description_en,
      stock: parseInt(p.stock, 10),
      discountPercentage: parseFloat(p.discountPercentage || 0),
      colors_en: handleJsonArrayField(p.color_en),
      colors_ar: handleJsonArrayField(p.color_ar),
      sizes: handleJsonArrayField(p.size),
      categories: handleJsonArrayField(p.category),
      category_names_ar: handleJsonArrayField(p.category_names_ar),
      category_names_en: handleJsonArrayField(p.category_names_en),
      rating: parseFloat(p.avg_rating),
      review_count: parseInt(p.review_count, 10),
      is_wishlist: Boolean(p.is_wishlist),
    }));

    // Calculate pagination info
    const currentPage = Math.floor(offset / limit) + 1;
    const totalPages = Math.ceil(totalItems / limit);

    return c.json(200, {
      success: true,
      data: mappedResults,
      pagination: {
        currentPage,
        itemsPerPage: limit,
        totalItems,
        totalPages
      }
    });
  },
  $apis.requireRecordAuth("users")
);
// routerAdd(
//   "GET",
//   "/api/new/home",
//   (c) => {
//     // 1. Authentication
//     const authRecord = c.get("authRecord");
//     if (!authRecord) {
//       throw new ApiError(401, "Unauthorized");
//     }
//     const userId = authRecord.id;

//     // 2. Query Definitions with reviews and ratings
//     const recommendationsQuery = `
//     WITH user_wishlist AS (
//       SELECT json_each.value AS product_id
//       FROM wish_list_items, json_each(wish_list_items.products)
//       WHERE wish_list_items.user = '${userId}'
//     ),
//     popular_products AS (
//       SELECT 
//         p.id,
//         COUNT(DISTINCT o.id) * 0.6 AS order_score,
//         COALESCE(AVG(r.rating), 3) * 0.4 AS review_score
//       FROM product p
//       LEFT JOIN (
//           orders o
//           JOIN json_each(o.products)
//           ON 1=1
//       ) ON o.status = 'success' AND json_each.value = p.id
//       LEFT JOIN reviews r ON r.product = p.id
//       GROUP BY p.id
//     )
//     SELECT
//       p.id as productId,
//       p.title_ar,
//       p.title_en,
//       p.price,
//       p.image,
//       p.description_ar,
//       p.description_en,
//       p.stock,
//       p.discountPercentage,
//       json_extract(p.category, '$[0]') AS category_id, 
//       cat.title_ar AS category_name_ar,
//       cat.title_en AS category_name_en,
//       (
//         COALESCE((SELECT 1 FROM user_wishlist w WHERE w.product_id = p.id), 0) * 0.5 +
//         COALESCE(pp.order_score, 0) * 0.3 +
//         COALESCE(pp.review_score, 0) * 0.2
//       ) AS recommendation_score,
//       COALESCE(pp.review_score / 0.4, 0) AS avg_rating,
//       (SELECT COUNT(*) FROM reviews r WHERE r.product = p.id) AS review_count,
//       EXISTS (
//         SELECT 1 
//         FROM wish_list_items w, json_each(w.products) j
//         WHERE w.user = '${userId}' AND j.value = p.id
//       ) AS is_wishlist
//     FROM product p
//     LEFT JOIN popular_products pp ON p.id = pp.id
//     LEFT JOIN categories cat ON cat.id = json_extract(p.category, '$[0]')
//     ORDER BY recommendation_score DESC
//     LIMIT 10;
//     `;

//     const trendingProductsQuery = `
//     WITH order_counts AS (
//       SELECT 
//         json_each.value AS product_id,
//         COUNT(*) AS order_count
//       FROM orders, json_each(orders.products)
//       WHERE orders.status = 'success'
//       GROUP BY product_id
//     )
//     SELECT 
//       p.id as productId,
//       p.title_ar,
//       p.title_en,
//       p.price,
//       p.image,
//       p.description_ar,
//       p.description_en,
//       p.stock,
//       p.discountPercentage,
//       json_extract(p.category, '$[0]') AS category_id,
//       cat.title_ar AS category_name_ar,
//       cat.title_en AS category_name_en,
//       oc.order_count as orderCount,
//       COALESCE((SELECT AVG(rating) FROM reviews r WHERE r.product = p.id), 0) AS avg_rating,
//       (SELECT COUNT(*) FROM reviews r WHERE r.product = p.id) AS review_count,
//       EXISTS (
//         SELECT 1 
//         FROM wish_list_items w, json_each(w.products) j
//         WHERE w.user = '${userId}' AND j.value = p.id
//       ) AS is_wishlist
//     FROM product p
//     JOIN order_counts oc ON p.id = oc.product_id
//     LEFT JOIN categories cat ON cat.id = json_extract(p.category, '$[0]')
//     ORDER BY oc.order_count DESC
//     LIMIT 10
//     `;

//     const newArrivalsQuery = `
//     SELECT 
//       p.id as productId,
//       p.title_ar,
//       p.title_en,
//       p.price,
//       p.image,
//       p.description_ar,
//       p.description_en,
//       p.stock,
//       p.discountPercentage,
//       json_extract(p.category, '$[0]') AS category_id,
//       cat.title_ar AS category_name_ar,
//       cat.title_en AS category_name_en,
//       COALESCE((SELECT AVG(rating) FROM reviews r WHERE r.product = p.id), 0) AS avg_rating,
//       (SELECT COUNT(*) FROM reviews r WHERE r.product = p.id) AS review_count,
//       EXISTS (
//         SELECT 1 
//         FROM wish_list_items w, json_each(w.products) j
//         WHERE w.user = '${userId}' AND j.value = p.id
//       ) AS is_wishlist
//     FROM product p
//     LEFT JOIN categories cat ON cat.id = json_extract(p.category, '$[0]')
//     ORDER BY p.created DESC 
//     LIMIT 10
//     `;
//     const bannerQuery = `
//     SELECT 
//       id,
//       title,
//       subtitle,
//       image,
//       link
//     FROM banner   
//   `;

//     // 3. Result Models with correct types
//     const recommendations = arrayOf(
//       new DynamicModel({
//         productId: "",
//         title_ar: "",
//         title_en: "",
//         price: 0.0,
//         image: "",
//         description_ar: "",
//         description_en: "",
//         stock: 0,
//         discountPercentage: 0,
//         category_id: "",
//         category_name_ar: "",
//         category_name_en: "",
//         recommendation_score: "0.0",
//         avg_rating: "0.0",
//         review_count: 0,
//         is_wishlist: false,
//       })
//     );

//     const trendingProducts = arrayOf(
//       new DynamicModel({
//         productId: "",
//         title_ar: "",
//         title_en: "",
//         price: 0.0,
//         image: "",
//         description_ar: "",
//         description_en: "",
//         stock: 0,
//         discountPercentage: 0,
//         orderCount: 0,
//         category_id: "",
//         category_name_ar: "",
//         category_name_en: "",
//         avg_rating: "0.0",
//         review_count: 0,
//         is_wishlist: false,
//       })
//     );

//     const newArrivals = arrayOf(
//       new DynamicModel({
//         productId: "",
//         title_ar: "",
//         title_en: "",
//         price: 0.0,
//         image: "",
//         description_ar: "",
//         description_en: "",
//         stock: 0,
//         discountPercentage: 0,
//         category_id: "",
//         category_name_ar: "",
//         category_name_en: "",
//         avg_rating: "0.0",
//         review_count: 0,
//         is_wishlist: false,
//       })
//     );

//     const userQueryData = arrayOf(
//       new DynamicModel({
//         search_query: "",
//       })
//     );
//     const banners = arrayOf(
//       new DynamicModel({
//         id: "",
//         title: "",
//         subtitle: "",
//         image: "",
//         link: "",
//       })
//     );
//     // Query all categories
//     const categories = arrayOf(
//       new DynamicModel({
//         id: "",
//         title_ar: "",
//         title_en: "",
//         image: "",
//         sub_categries: ""
//       })
//     );
// // Step 2: Load products with category relations
// const products = arrayOf(
//   new DynamicModel({ category: "" })
// );
//     // Helper function to handle image field
//     const handleImageField = (image) => {
//       if (!image) return [];
//       try {
//         // Try parsing as JSON array
//         const parsed = JSON.parse(image);
//         return Array.isArray(parsed) ? parsed : [image];
//       } catch {
//         // If not JSON, treat as single filename
//         return [image];
//       }
//     };

//     // 4. Execute Queries with Error Handling
//     try {
//       $app.db().newQuery(recommendationsQuery).all(recommendations);
//     } catch (e) {
//       console.error("Recommendations query failed:", e);
//       throw new ApiError(
//         500,
//         "Failed to generate personalized recommendations"
//       );
//     }

//     try {
//       $app.db().newQuery(newArrivalsQuery).all(newArrivals);
//     } catch (e) {
//       console.error("New arrivals query failed:", e);
//       newArrivals.length = 0;
//     }

//     try {
//       $app.db().newQuery(trendingProductsQuery).all(trendingProducts);
//     } catch (e) {
//       console.error("Trending products query failed:", e);
//       trendingProducts.length = 0;
//     }

//     try {
//       $app
//         .db()
//         .select("search_query", "user")
//         .from("user_search")
//         .andWhere($dbx.like("user", authRecord.id))
//         .limit(5)
//         .orderBy("created ASC")
//         .all(userQueryData);
//     } catch (e) {
//       console.error("User query failed:", e);
//     }

//     try {
//       $app.db().newQuery(bannerQuery).all(banners);
//       console.log(`Fetched ${banners.length} banners`);
//     } catch (e) {
//       console.error("Banner query failed:", e.message || e);
//       if (e.originalError) {
//         console.error("Original database error:", e.originalError);
//       }
//       throw new ApiError(500, "Failed to fetch banners");
//     }


//     try {
//       $app.db().newQuery(`
//         SELECT id, title_ar, title_en, image, sub_categries
//         FROM categories
//       `).all(categories);
//     } catch (e) {
//       console.error("Categories query failed:", e);
//       throw new ApiError(500, "Failed to fetch categories");
//     }
  
    
  
//     try {
//       $app.db().newQuery(`SELECT category FROM product`).all(products);
//     } catch (e) {
//       console.error("Product query failed:", e);
//       // Fail-safe: if product query fails, category counts default to 0
//     }

//   // Step 3: Build category → product count map
//   const categoryCountMap = new Map();

//   for (const p of products) {
//     try {
//       if (p.category) {
//         const categoryIds = JSON.parse(p.category);
//         if (Array.isArray(categoryIds)) {
//           for (const id of categoryIds) {
//             if (typeof id === "string" && id.trim() !== "") {
//               categoryCountMap.set(id, (categoryCountMap.get(id) || 0) + 1);
//             }
//           }
//         }
//       }
//     } catch {
//       // Ignore parse errors
//     }
//   }

//   // Step 4: Image parser
//   const parseImage2 = (image) => {
//     if (!image) return [];
//     try {
//       const parsed = JSON.parse(image);
//       return Array.isArray(parsed) ? parsed : [parsed.toString()];
//     } catch {
//       return [image.toString()];
//     }
//   };

//   // Step 5: Prepare category nodes
//   const categoryMap = new Map();
//   const childToParentMap = new Map();
//   const allChildIds = new Set();

//   for (const raw of categories) {
//     let subList = [];
//     try {
//       if (raw.sub_categries) {
//         subList = JSON.parse(raw.sub_categries);
//         if (!Array.isArray(subList)) subList = [];
//       }
//     } catch {
//       subList = [];
//     }

//     const node = {
//       id: raw.id,
//       title: {
//         ar: raw.title_ar,
//         en: raw.title_en
//       },
//       image: parseImage2(raw.image),
//       totalItemsNumber: categoryCountMap.get(raw.id) || 0,
//       children: [],
//       expanded: false,
//       level: 0
//     };

//     categoryMap.set(raw.id, node);

//     for (const childId of subList) {
//       if (typeof childId === "string" && childId.trim() !== "") {
//         childToParentMap.set(childId, raw.id);
//         allChildIds.add(childId);
//       }
//     }
//   }

//   // Step 6: Build tree hierarchy
//   const rootNodes = [];

//   for (const [id, node] of categoryMap.entries()) {
//     const parentId = childToParentMap.get(id);
//     if (parentId && categoryMap.has(parentId)) {
//       const parent = categoryMap.get(parentId);
//       node.level = parent.level + 1;
//       parent.children.push(node);
//     } else if (!allChildIds.has(id)) {
//       rootNodes.push(node); // Only root-level if not a child elsewhere
//     }
//   }

//   // Step 7: Optional sorting of children by title
//   const sortTree = (node) => {
//     node.children.sort((a, b) => a.title.en.localeCompare(b.title.en));
//     node.children.forEach(sortTree);
//   };

//   rootNodes.forEach(sortTree);

 

//        //search user wishlis
//        const userWishListId = arrayOf(
//         new DynamicModel({
//           id: "",
//         })
//       );
//       try {
//         $app
//           .db()
//           .select("id", "user")
//           .from("wish_list_items")
//           .andWhere($dbx.like("user", authRecord.id))
//           .limit(1)
//           .orderBy("created ASC")
//           .all(userWishListId);
//       } catch (e) {
//         console.error("wish_list_items query failed:", e);
//       }
 


//     // 5. Return response with proper mapping
//     return c.json(200, {
//       success: true,
//       data: {
//         userWishListId:userWishListId.length>0?userWishListId[0].id:null,
//         recentSearches: userQueryData,
//         recommendations: recommendations.map((r) => ({
//           productId: r.productId,
//           title_ar: r.title_ar,
//           title_en: r.title_en,
//           price: r.price,
//           image: handleImageField(r.image),
//           description_ar: r.description_ar,
//           description_en: r.description_en,
//           stock: r.stock,
//           discountPercentage: r.discountPercentage,
//           category: r.category_id,
//           category_name_ar: r.category_name_ar,
//           category_name_en: r.category_name_en,
//           recommendation_score: parseFloat(r.recommendation_score),
//           rating: parseFloat(r.avg_rating),
//           review_count: parseInt(r.review_count),
//           is_wishlist: r.is_wishlist,
//         })),
//         new_arrivals: newArrivals.map((n) => ({
//           productId: n.productId,
//           title_ar: n.title_ar,
//           title_en: n.title_en,
//           price: n.price,
//           image: handleImageField(n.image),
//           description_ar: n.description_ar,
//           description_en: n.description_en,
//           stock: n.stock,
//           discountPercentage: n.discountPercentage,
//           category: n.category_id,
//           category_name_ar: n.category_name_ar,
//           category_name_en: n.category_name_en,
//           rating: parseFloat(n.avg_rating),
//           review_count: parseInt(n.review_count),
//           is_wishlist: n.is_wishlist,
//         })),
//         trending_products: trendingProducts.map((t) => ({
//           productId: t.productId,
//           title_ar: t.title_ar,
//           title_en: t.title_en,
//           price: t.price,
//           image: handleImageField(t.image),
//           description_ar: t.description_ar,
//           description_en: t.description_en,
//           stock: t.stock,
//           discountPercentage: t.discountPercentage,
//           category: t.category_id,
//           category_name_ar: t.category_name_ar,
//           category_name_en: t.category_name_en,
//           orderCount: t.orderCount,
//           rating: parseFloat(t.avg_rating),
//           review_count: parseInt(t.review_count),
//           is_wishlist: t.is_wishlist,
//         })),
//         banners: banners,
//         categories: rootNodes,
//       },
//     });
//   },
//   $apis.requireRecordAuth("users")
// );


// routerAdd(
//   "GET",
//   "/api/new/search",
//   (c) => {
//     // 1. Authentication
//     const authRecord = c.get("authRecord");
//     if (!authRecord) {
//       console.log("Authentication failed: User not authorized.");
//       throw new ApiError(401, "Unauthorized");
//     }
//     console.log(`User authenticated: ${authRecord.id}`);

//     // 2. Get Query Parameters
//     const queryParams = c.queryParam;
//     const searchQuery = queryParams("q") || "";
//     let categoryFilter = queryParams("category") || "";
//     let colorFilter = queryParams("colors") || "";
//     let sizeFilter = queryParams("sizes") || "";
    
//     const parseNumberParam = (param, defaultValue = null) => {
//       const value = queryParams(param);
//       if (value === null || value === undefined) return defaultValue;
//       const num = parseFloat(value);
//       return isNaN(num) ? defaultValue : num;
//     };

//     const minPrice = parseNumberParam("minPrice");
//     const maxPrice = parseNumberParam("maxPrice");
//     const minRating = parseNumberParam("minRating");
//     const orderBy = queryParams("orderBy") || "title_en";
//     const orderDirection = queryParams("orderDirection") || "ASC";
//     const limit = parseInt(queryParams("limit")) || 10;
//     const offset = parseInt(queryParams("offset")) || 0;

//     // Save search query if not empty
//     if (searchQuery) {
//       try {
//         const userSearchCollection = $app
//           .dao()
//           .findCollectionByNameOrId("user_search");
//         if (userSearchCollection) {
//           const newSavedSearch = new Record(userSearchCollection);
//           newSavedSearch.set("search_query", searchQuery);
//           newSavedSearch.set("user", authRecord.id);
//           $app.dao().save(newSavedSearch);
//           console.log("Search saved successfully");
//         }
//       } catch (error) {
//         console.error("Save failed:", error);
//       }
//     }

//     // Handle category IDs
//     let categoryIds = [];
//     if (categoryFilter) {
//       categoryIds = categoryFilter
//         .split(",")
//         .map((id) => String(id).trim())
//         .filter((id) => id);
//     }

//     // Handle color filters
//     let colors = [];
//     if (colorFilter) {
//       colors = colorFilter
//         .split(",")
//         .map((color) => String(color).trim())
//         .filter((color) => color);
//     }

//     // Handle size filters
//     let sizes = [];
//     if (sizeFilter) {
//       sizes = sizeFilter
//         .split(",")
//         .map((size) => String(size).trim())
//         .filter((size) => size);
//     }

//     // 3. Construct SQL Query with category names
//     let sqlQuery = `
//       SELECT
//         p.id as productId,
//         p.title_ar,
//         p.title_en,
//         p.price,
//         p.image,
//         p.description_ar,
//         p.description_en,
//         p.stock,
//         p.discountPercentage,
//         p.color_en,
//         p.color_ar,
//         p.size,
//         p.category,
//         -- Get category names using JSON functions
//         (
//           SELECT json_group_array(cat.title_ar)
//           FROM categories cat
//           WHERE cat.id IN (SELECT value FROM json_each(p.category))
//         ) AS category_names_ar,
//         (
//           SELECT json_group_array(cat.title_en)
//           FROM categories cat
//           WHERE cat.id IN (SELECT value FROM json_each(p.category))
//         ) AS category_names_en,
//         COALESCE((SELECT AVG(rating) FROM reviews r WHERE r.product = p.id), 0) AS avg_rating,
//         (SELECT COUNT(*) FROM reviews r WHERE r.product = p.id) AS review_count,
//         EXISTS (
//           SELECT 1 
//           FROM wish_list_items w, json_each(w.products) j
//           WHERE w.user = {:userId} AND j.value = p.id
//         ) AS is_wishlist
//       FROM product p
//       WHERE 1=1
//     `;

//     const queryArgs = { userId: authRecord.id };

//     // Search condition
//     if (searchQuery) {
//       sqlQuery += `
//         AND (
//           p.id LIKE {:searchQuery} OR
//           p.title_en LIKE {:searchQuery} OR
//           p.title_ar LIKE {:searchQuery} OR
//           p.description_en LIKE {:searchQuery} OR
//           p.description_ar LIKE {:searchQuery}
//         )
//       `;
//       queryArgs.searchQuery = `%${searchQuery}%`;
//     }

//     // Category condition
//     if (categoryIds.length > 0) {
//       const categoryPlaceholders = categoryIds
//         .map((_, index) => `{:cat${index}}`)
//         .join(", ");

//       sqlQuery += `
//         AND EXISTS (
//           SELECT 1 FROM json_each(p.category) AS j
//           WHERE j.value IN (${categoryPlaceholders})
//         )
//       `;

//       categoryIds.forEach((id, index) => {
//         queryArgs[`cat${index}`] = id;
//       });
//     }

//     // Color condition
//     if (colors.length > 0) {
//       const colorPlaceholders = colors
//         .map((_, index) => `{:color${index}}`)
//         .join(", ");

//       sqlQuery += `
//         AND EXISTS (
//           SELECT 1 FROM json_each(p.color_en) AS j
//           WHERE j.value IN (${colorPlaceholders})
//         )
//       `;

//       colors.forEach((color, index) => {
//         queryArgs[`color${index}`] = color;
//       });
//     }

//     // Size condition
//     if (sizes.length > 0) {
//       const sizePlaceholders = sizes
//         .map((_, index) => `{:size${index}}`)
//         .join(", ");

//       sqlQuery += `
//         AND EXISTS (
//           SELECT 1 FROM json_each(p.size) AS j
//           WHERE j.value IN (${sizePlaceholders})
//         )
//       `;

//       sizes.forEach((size, index) => {
//         queryArgs[`size${index}`] = size;
//       });
//     }

//     // Price filtering
//     if (minPrice !== null) {
//       sqlQuery += ` AND p.price >= {:minPrice}`;
//       queryArgs.minPrice = minPrice;
//     }

//     if (maxPrice !== null) {
//       sqlQuery += ` AND p.price <= {:maxPrice}`;
//       queryArgs.maxPrice = maxPrice;
//     }

//     // Rating filtering
//     if (minRating !== null) {
//       sqlQuery += ` AND (
//         SELECT AVG(rating) FROM reviews r WHERE r.product = p.id
//       ) >= {:minRating}`;
//       queryArgs.minRating = minRating;
//     }

//     // Add grouping
//     sqlQuery += ` GROUP BY p.id `;

//     // Add ordering
//     const allowedOrderBy = [
//       "title_en",
//       "title_ar",
//       "price",
//       "stock",
//       "created",
//       "avg_rating",
//     ];
//     const actualOrderBy = allowedOrderBy.includes(orderBy)
//       ? orderBy
//       : "title_en";
//     const actualOrderDirection =
//       orderDirection.toUpperCase() === "DESC" ? "DESC" : "ASC";

//     sqlQuery += ` ORDER BY ${
//       actualOrderBy === "avg_rating" ? "avg_rating" : "p." + actualOrderBy
//     } ${actualOrderDirection}`;

//     // Add pagination
//     sqlQuery += ` LIMIT {:limit} OFFSET {:offset}`;
//     queryArgs.limit = limit;
//     queryArgs.offset = offset;

//     console.log("SQL Query:", sqlQuery);
//     console.log("Query Args:", JSON.stringify(queryArgs));

//     // 4. Result Model with category names
//     const searchResults = arrayOf(
//       new DynamicModel({
//         productId: "",
//         title_ar: "",
//         title_en: "",
//         price: 0,
//         image: [],
//         description_ar: "",
//         description_en: "",
//         stock: 0,
//         discountPercentage: 0,
//         color_en: "",
//         color_ar: "",
//         size: "",
//         category: "",
//         category_names_ar: "",
//         category_names_en: "",
//         avg_rating: "0",
//         review_count: 0,
//         is_wishlist: false,
//       })
//     );

//     // Helper function to handle image field
//     const handleImageField = (image) => {
//       if (!image) return [];
//       try {
//         const parsed = JSON.parse(image);
//         return Array.isArray(parsed) ? parsed : [image];
//       } catch (e) {
//         return [image];
//       }
//     };
    
//     // Helper function to handle JSON array fields
//     const handleJsonArrayField = (field) => {
//       if (!field) return [];
//       try {
//         // If it's already an array, return it
//         if (Array.isArray(field)) return field;
        
//         // If it's a string, try to parse it as JSON
//         if (typeof field === 'string') {
//           const parsed = JSON.parse(field);
//           return Array.isArray(parsed) ? parsed : [parsed];
//         }
        
//         // If it's something else, wrap it in an array
//         return [field];
//       } catch (e) {
//         console.error('Error parsing JSON array:', e);
//         return [field];
//       }
//     };

//     //search user wishlist
//     const userWishListId = arrayOf(
//       new DynamicModel({
//         id: "",
//       })
//     );
//     try {
//       $app
//         .db()
//         .select("id", "user")
//         .from("wish_list_items")
//         .andWhere($dbx.like("user", authRecord.id))
//         .limit(1)
//         .orderBy("created ASC")
//         .all(userWishListId);
//     } catch (e) {
//       console.error("wish_list_items query failed:", e);
//     }

//     // 5. Execute Query
//     try {
//       $app.db().newQuery(sqlQuery).bind(queryArgs).all(searchResults);
//     } catch (e) {
//       console.error("Search query failed:", e);
//       throw new ApiError(500, "Failed to search products");
//     }

//     // 6. Return response with category names
//     const mappedResults = searchResults.map((p) => ({
//       userId: authRecord.id,
//       userWishListId: userWishListId.length > 0 ? userWishListId[0].id : 'NotFound',
//       productId: p.productId,
//       title_ar: p.title_ar,
//       title_en: p.title_en,
//       price: parseFloat(p.price),
//       image: handleImageField(p.image),
//       description_ar: p.description_ar,
//       description_en: p.description_en,
//       stock: parseInt(p.stock, 10),
//       discountPercentage: parseFloat(p.discountPercentage || 0),
//       colors_en: handleJsonArrayField(p.color_en),
//       colors_ar: handleJsonArrayField(p.color_ar),
//       sizes: handleJsonArrayField(p.size),
//       categories: handleJsonArrayField(p.category),
//       category_names_ar: handleJsonArrayField(p.category_names_ar),
//       category_names_en: handleJsonArrayField(p.category_names_en),
//       rating: parseFloat(p.avg_rating),
//       review_count: parseInt(p.review_count, 10),
//       is_wishlist: Boolean(p.is_wishlist),
//     }));

//     return c.json(200, {
//       success: true,
//       data: mappedResults,
//     });
//   },
//   $apis.requireRecordAuth("users")
// );

routerAdd(
  "DELETE",
  "/api/new/search/:query",
  (c) => {
    // 1. Authentication
    const authRecord = c.get("authRecord");
    if (!authRecord) {
      throw new ApiError(401, "Unauthorized");
    }

    // 2. Get the search query from URL parameter
    const searchQuery = c.pathParam("query");
    if (!searchQuery) {
      throw new ApiError(400, "Search query is required");
    }

    // 3. Delete the search query for this user
    try {
      $app
        .dao()
        .db()
        .newQuery(
          `DELETE FROM user_search WHERE user = {:userId} AND search_query = {:query}`
        )
        .bind({
          userId: authRecord.id,
          query: searchQuery,
        })
        .execute();
    } catch (e) {
      console.error("Delete search query failed:", e);
      throw new ApiError(500, "Failed to remove search query");
    }

    return c.json(200, {
      success: true,
      message: "Search query removed successfully",
    });
  },
  $apis.requireRecordAuth("users")
);

routerAdd(
  "GET",
  "/api/new/products/:id",
  (c) => {
    // 1. Authentication
    const authRecord = c.get("authRecord");
    if (!authRecord) {
      throw new ApiError(401, "Unauthorized");
    }
    const userId = authRecord.id;
    const productId = c.pathParam("id");

    // 2. Query for the specific product
    const productQuery = `
      SELECT
        p.id as productId,
        p.title_ar,
        p.title_en,
        p.price,
        p.image,
        p.description_ar,
        p.description_en,
        p.stock,
        p.discountPercentage,
        p.category,
        p.size,
        p.color_en,
        p.color_ar,
        cat.title_ar AS category_name_ar,
        cat.title_en AS category_name_en,
        COALESCE((SELECT AVG(rating) FROM reviews r WHERE r.product = p.id), 0) AS avg_rating,
        (SELECT COUNT(*) FROM reviews r WHERE r.product = p.id) AS review_count,
        EXISTS (
          SELECT 1 
          FROM wish_list_items w, json_each(w.products) j
          WHERE w.user = '${userId}' AND j.value = p.id
        ) AS is_wishlist
      FROM product p
      LEFT JOIN categories cat ON cat.id = json_extract(p.category, '$[0]')
      WHERE p.id = '${productId}'
    `;

    // 3. Query for recommended products (similar category)
    const recommendedProductsQuery = `
      WITH product_categories AS (
        SELECT json_each.value AS category_id
        FROM product, json_each(product.category)
        WHERE product.id = '${productId}'
      )
      SELECT
        p.id as productId,
        p.title_ar,
        p.title_en,
        p.price,
        p.image,
        p.description_ar,
        p.description_en,
        p.stock,
        p.discountPercentage,
        p.size,
        p.color_en,
        p.color_ar,
        json_extract(p.category, '$[0]') AS category_id,
        cat.title_ar AS category_name_ar,
        cat.title_en AS category_name_en,
        COALESCE((SELECT AVG(rating) FROM reviews r WHERE r.product = p.id), 0) AS avg_rating,
        (SELECT COUNT(*) FROM reviews r WHERE r.product = p.id) AS review_count,
        EXISTS (
          SELECT 1 
          FROM wish_list_items w, json_each(w.products) j
          WHERE w.user = '${userId}' AND j.value = p.id
        ) AS is_wishlist
      FROM product p
      LEFT JOIN categories cat ON cat.id = json_extract(p.category, '$[0]')
      WHERE p.id != '${productId}'
        AND EXISTS (
          SELECT 1 FROM json_each(p.category) AS j
          WHERE j.value IN (SELECT category_id FROM product_categories)
        )
      ORDER BY avg_rating DESC, review_count DESC
      LIMIT 5
    `;

    // 4. Query for top 5 reviews
    const topReviewsQuery = `
      SELECT
        r.id,
        r.rating,
        r.comment,
        r.created,
        u.id as user_id,
        u.name as user_name,
        u.avatar as user_avatar
      FROM reviews r
      LEFT JOIN users u ON r.user = u.id
      WHERE r.product = '${productId}'
      ORDER BY r.created DESC
      LIMIT 5
    `;

    // 5. Result Models
    const product = new DynamicModel({
      productId: "",
      title_ar: "",
      title_en: "",
      price: 0,
      image: "",
      description_ar: "",
      description_en: "",
      stock: 0,
      discountPercentage: 0,
      category: "",
      size: "",
      color_en: "",
      color_ar: "",
      category_name_ar: "",
      category_name_en: "",
      avg_rating: "0",
      review_count: 0,
      is_wishlist: false,
    });

    const recommendedProducts = arrayOf(
      new DynamicModel({
        productId: "",
        title_ar: "",
        title_en: "",
        price: 0,
        image: "",
        description_ar: "",
        description_en: "",
        stock: 0,
        discountPercentage: 0,
        size: "",
        color_en: "",
        color_ar: "",
        category_id: "",
        category_name_ar: "",
        category_name_en: "",
        avg_rating: "0",
        review_count: 0,
        is_wishlist: false,
      })
    );

    const topReviews = arrayOf(
      new DynamicModel({
        id: "",
        rating: 0,
        comment: "",
        created: "",
        user_id: "",
        user_name: "",
        user_avatar: "",
      })
    );

    // Helper function to handle image field
    const handleImageField = (image) => {
      if (!image) return [];
      try {
        const parsed = JSON.parse(image);
        return Array.isArray(parsed) ? parsed : [image];
      } catch {
        return [image];
      }
    };

    // Helper function to handle JSON array fields
    const parseJsonArrayField = (field) => {
      if (!field) return [];
      try {
        const parsed = JSON.parse(field);
        return Array.isArray(parsed) ? parsed : [field];
      } catch {
        return [field];
      }
    };

    // 6. Execute Queries
    try {
      $app.db().newQuery(productQuery).one(product);
    } catch (e) {
      console.error("Product query failed:", e);
      throw new ApiError(404, "Product not found");
    }

    try {
      $app.db().newQuery(recommendedProductsQuery).all(recommendedProducts);
    } catch (e) {
      console.error("Recommended products query failed:", e);
      // Continue even if recommended products fail
    }

    try {
      $app.db().newQuery(topReviewsQuery).all(topReviews);
    } catch (e) {
      console.error("Top reviews query failed:", e);
      // Continue even if reviews fail
    }

    // 7. Get user wishlist ID
    const userWishListId = arrayOf(
      new DynamicModel({
        id: "",
      })
    );
    try {
      $app
        .db()
        .select("id", "user")
        .from("wish_list_items")
        .andWhere($dbx.like("user", authRecord.id))
        .limit(1)
        .orderBy("created ASC")
        .all(userWishListId);
    } catch (e) {
      console.error("wish_list_items query failed:", e);
    }

    // 8. Return response
    return c.json(200, {
      success: true,
      data: {
        userId: authRecord.id,
        userWishListId: userWishListId.length > 0 ? userWishListId[0].id : 'NotFound',
        product: {
          productId: product.productId,
          title_ar: product.title_ar,
          title_en: product.title_en,
          price: parseFloat(product.price),
          image: handleImageField(product.image),
          description_ar: product.description_ar,
          description_en: product.description_en,
          stock: parseInt(product.stock, 10),
          discountPercentage: parseFloat(product.discountPercentage || 0),
          category: product.category,
          category_name_ar: product.category_name_ar,
          category_name_en: product.category_name_en,
          rating: parseFloat(product.avg_rating),
          review_count: parseInt(product.review_count, 10),
          is_wishlist: Boolean(product.is_wishlist),
          size: parseJsonArrayField(product.size),
          color_en: parseJsonArrayField(product.color_en),
          color_ar: parseJsonArrayField(product.color_ar),
        },
        recommended_products: recommendedProducts.map((p) => ({
          productId: p.productId,
          title_ar: p.title_ar,
          title_en: p.title_en,
          price: parseFloat(p.price),
          image: handleImageField(p.image),
          description_ar: p.description_ar,
          description_en: p.description_en,
          stock: parseInt(p.stock, 10),
          discountPercentage: parseFloat(p.discountPercentage || 0),
          category: p.category_id,
          category_name_ar: p.category_name_ar,
          category_name_en: p.category_name_en,
          rating: parseFloat(p.avg_rating),
          review_count: parseInt(p.review_count, 10),
          is_wishlist: Boolean(p.is_wishlist),
          size: parseJsonArrayField(p.size),
          color_en: parseJsonArrayField(p.color_en),
          color_ar: parseJsonArrayField(p.color_ar),
        })),
        top_reviews: topReviews.map((r) => ({
          id: r.id,
          rating: parseFloat(r.rating),
          comment: r.comment,
          created: r.created,
          user: {
            id: r.user_id,
            name: r.user_name,
            avatar: handleImageField(r.user_avatar),
          },
        })),
      },
    });
  },
  $apis.requireRecordAuth("users")
);