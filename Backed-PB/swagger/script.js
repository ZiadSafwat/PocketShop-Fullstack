 
        document.addEventListener('DOMContentLoaded', function() {
            const currentDate = new Date();
             
            // Load the PocketBase OpenAPI specification
            loadPocketBaseSpec();
            
            function loadPocketBaseSpec() {
                // Use the actual API endpoint
                fetch('http://127.0.0.1:8090/api/collections/solid_data/records/mmf3off8f3r9frx')
                    .then(response => {
                        if (!response.ok) {
                            throw new Error(`HTTP error! status: ${response.status}`);
                        }
                        return response.json();
                    })
                    .then(data => {
                        // Extract the OpenAPI spec from the 'json' property
                        const spec = data.json;
                        
                        // Hide loading spinner
                        document.getElementById('loading').style.display = 'none';
                        
                        // Update header info
                        document.getElementById('api-version').textContent = spec.info.version || 'N/A';
                        document.getElementById('api-server').textContent = spec.servers?.[0]?.url || 'N/A';
                        
                        // Initialize Swagger UI with the spec
                        initSwaggerUI(spec);
                    })
                    .catch(error => {
                        console.error('Error loading PocketBase API spec:', error);
                        document.getElementById('loading').style.display = 'none';
                        document.getElementById('error').style.display = 'block';
                        document.getElementById('error-details').textContent = error.message;
                    });
            }
            
            function initSwaggerUI(spec) {
                // Show Swagger container
                document.getElementById('swagger-container').style.display = 'block';
                
                // Initialize Swagger UI
                const ui = SwaggerUIBundle({
                    spec: spec,
                    dom_id: '#swagger-ui',
                    deepLinking: true,
                    presets: [
                        SwaggerUIBundle.presets.apis,
                        SwaggerUIStandalonePreset
                    ],
                    plugins: [
                        SwaggerUIBundle.plugins.DownloadUrl
                    ],
                    layout: "StandaloneLayout",
                    tryItOutEnabled: true,
                    requestSnippetsEnabled: true,
                    requestSnippets: {
                        generators: {
                            curl_bash: {
                                title: "cURL (bash)",
                                syntax: "bash"
                            },
                            curl_powershell: {
                                title: "cURL (PowerShell)",
                                syntax: "powershell"
                            },
                            curl_cmd: {
                                title: "cURL (CMD)",
                                syntax: "bash"
                            },
                            node_fetch: {
                                title: "Fetch (Node.js)",
                                syntax: "javascript"
                            },
                            browser_fetch: {
                                title: "Fetch (Browser)",
                                syntax: "javascript"
                            }
                        },
                        defaultExpanded: true,
                        languages: null
                    },
                    // Add OAuth2 redirect URL
                    oauth2RedirectUrl: window.location.href.replace(/\/[^\/]*$/, '/oauth2-redirect.html'),
                    // Custom theme colors
                    theme: {
                        colors: {
                            primary: {
                                50: '#f5f3ff',
                                100: '#ede9fe',
                                200: '#ddd6fe',
                                300: '#c4b5fd',
                                400: '#a78bfa',
                                500: '#8b5cf6',
                                600: '#7c3aed',
                                700: '#6d28d9',
                                800: '#5b21b6',
                                900: '#4c1d95',
                            }
                        }
                    }
                });
                
                // Initialize OAuth
                ui.initOAuth({
                    appName: "PocketBase API Documentation",
                    clientId: "your-client-id",  // Replace with your actual client ID
                    scopes: "openapi"
                });
            }
        });
 
