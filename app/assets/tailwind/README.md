# Custom Tailwind Components

This document outlines the custom Tailwind CSS classes created for the admin interface to maintain consistency and reduce code duplication.

## Admin Container Components

### Basic Container
- `.admin-container` - Main container with white background, shadow, rounded corners, and orange border
- `.admin-container-header` - Header section with padding and bottom border
- `.admin-container-title` - Main title styling
- `.admin-container-subtitle` - Subtitle styling
- `.admin-container-content` - Content area with overflow handling

### Usage Example:
```html
<div class="admin-container">
  <div class="admin-container-header">
    <h3 class="admin-container-title">Page Title</h3>
    <p class="admin-container-subtitle">Page description</p>
  </div>
  <div class="admin-container-content">
    <!-- Content here -->
  </div>
</div>
```

## Admin Table Components

### Table Structure
- `.admin-table` - Main table with dividers
- `.admin-table-header` - Table header background
- `.admin-table-header-cell` - Left-aligned header cell
- `.admin-table-header-cell-center` - Center-aligned header cell
- `.admin-table-header-cell-right` - Right-aligned header cell
- `.admin-table-body` - Table body with dividers
- `.admin-table-row` - Table row with hover effect
- `.admin-table-cell` - Left-aligned cell
- `.admin-table-cell-center` - Center-aligned cell
- `.admin-table-cell-right` - Right-aligned cell

### Usage Example:
```html
<table class="admin-table">
  <thead class="admin-table-header">
    <tr>
      <th class="admin-table-header-cell">Name</th>
      <th class="admin-table-header-cell-center">Price</th>
      <th class="admin-table-header-cell-right">Actions</th>
    </tr>
  </thead>
  <tbody class="admin-table-body">
    <tr class="admin-table-row">
      <td class="admin-table-cell">Product Name</td>
      <td class="admin-table-cell-center">$10.00</td>
      <td class="admin-table-cell-right">Actions</td>
    </tr>
  </tbody>
</table>
```

## Admin Button Components

### Button Types
- `.admin-btn-primary` - Primary orange button
- `.admin-btn-secondary` - Secondary outlined button
- `.admin-btn-danger` - Red danger button

### Action Buttons
- `.admin-action-btn` - Icon action button (orange)
- `.admin-action-btn-danger` - Icon action button (red)
- `.admin-action-btn-group` - Container for action buttons

### Usage Example:
```html
<%= link_to "Add New", new_path, class: "admin-btn-primary" %>
<%= link_to "Cancel", cancel_path, class: "admin-btn-secondary" %>

<div class="admin-action-btn-group">
  <%= link_to view_path, class: "admin-action-btn" do %>
    <!-- Icon here -->
  <% end %>
</div>
```

## Admin Card Components

### Basic Cards
- `.admin-card` - Standard card with padding and border
- `.admin-card-header` - Card header section
- `.admin-card-title` - Card title styling
- `.admin-card-content` - Card content area

### Stats Cards
- `.admin-stats-card` - Statistics card
- `.admin-stats-icon` - Icon container
- `.admin-stats-icon-orange` - Orange icon background
- `.admin-stats-icon-green` - Green icon background
- `.admin-stats-icon-yellow` - Yellow icon background
- `.admin-stats-icon-blue` - Blue icon background
- `.admin-stats-content` - Stats content area
- `.admin-stats-label` - Stats label
- `.admin-stats-value` - Stats value
- `.admin-stats-value-orange` - Orange value color
- `.admin-stats-value-green` - Green value color
- `.admin-stats-value-yellow` - Yellow value color
- `.admin-stats-value-blue` - Blue value color

### Usage Example:
```html
<div class="admin-stats-card">
  <div class="flex items-center">
    <div class="admin-stats-icon admin-stats-icon-orange">
      <!-- Icon here -->
    </div>
    <div class="admin-stats-content">
      <h2 class="admin-stats-label">Total Orders</h2>
      <p class="admin-stats-value admin-stats-value-orange">150</p>
    </div>
  </div>
</div>
```

## Admin Status Badges

### Status Types
- `.admin-status-badge` - Base badge styling
- `.admin-status-pending` - Yellow pending status
- `.admin-status-processing` - Blue processing status
- `.admin-status-completed` - Green completed status
- `.admin-status-cancelled` - Red cancelled status
- `.admin-status-default` - Gray default status

### Usage Example:
```html
<span class="admin-status-badge admin-status-pending">Pending</span>
<span class="admin-status-badge admin-status-completed">Completed</span>
```

## Form Components

### Form Elements
- `.form-group` - Form field group with margin
- `.form-label` - Form label styling
- `.form-input` - Text input styling
- `.form-input-error` - Text input with error state
- `.form-textarea` - Textarea styling
- `.form-select` - Select dropdown styling
- `.form-checkbox` - Checkbox styling
- `.form-radio` - Radio button styling
- `.form-error` - Error message styling
- `.form-help` - Help text styling

### Form Buttons
- `.form-btn-primary` - Full-width primary button
- `.form-btn-secondary` - Full-width secondary button

### Usage Example:
```html
<div class="form-group">
  <label class="form-label">Product Name</label>
  <input type="text" class="form-input" placeholder="Enter product name">
  <p class="form-help">Enter a descriptive name for your product</p>
</div>

<button type="submit" class="form-btn-primary">Save Product</button>
```

## Grid Layouts

### Layout Classes
- `.admin-grid-stats` - 4-column stats grid (responsive)
- `.admin-grid-content` - 2-column content grid (responsive)

### Usage Example:
```html
<div class="admin-grid-stats">
  <!-- Stats cards here -->
</div>

<div class="admin-grid-content">
  <!-- Content cards here -->
</div>
```

## List Components

### List Structure
- `.admin-list` - List container
- `.admin-list-items` - List items container
- `.admin-list-item` - Individual list item
- `.admin-list-item-content` - List item content wrapper
- `.admin-list-item-main` - Main content area
- `.admin-list-item-title` - Item title
- `.admin-list-item-subtitle` - Item subtitle
- `.admin-list-item-meta` - Item metadata
- `.admin-list-item-actions` - Item actions area

### Usage Example:
```html
<div class="admin-list">
  <ul class="admin-list-items">
    <li class="admin-list-item">
      <div class="admin-list-item-content">
        <div class="admin-list-item-main">
          <p class="admin-list-item-title">Order #123</p>
          <p class="admin-list-item-subtitle">Customer Name</p>
          <p class="admin-list-item-meta">Date</p>
        </div>
        <div class="admin-list-item-actions">
          <!-- Actions here -->
        </div>
      </div>
    </li>
  </ul>
</div>
```

## Chart Components

### Chart Structure
- `.admin-chart-container` - Chart container
- `.admin-chart-header` - Chart header
- `.admin-chart-content` - Chart content area
- `.admin-chart-bar` - Bar chart container
- `.admin-chart-bar-item` - Individual bar item
- `.admin-chart-bar-value` - Bar value
- `.admin-chart-bar-divider` - Bar divider
- `.admin-chart-bar-line` - Divider line
- `.admin-chart-bar-dot` - Divider dot
- `.admin-chart-bar-label` - Bar label
- `.admin-chart-bar-day` - Day label
- `.admin-chart-bar-date` - Date label

## Product Components

### Product Elements
- `.product-avatar` - Product avatar container
- `.product-avatar-image` - Product image
- `.product-avatar-placeholder` - Avatar placeholder
- `.product-avatar-initial` - Avatar initial
- `.product-info` - Product information
- `.product-name` - Product name
- `.product-description` - Product description
- `.product-price` - Product price

## Link Components

### Link Types
- `.admin-link` - Standard admin link
- `.admin-link-primary` - Primary admin link

## Benefits

1. **Consistency**: All admin pages will have consistent styling
2. **Maintainability**: Changes to design can be made in one place
3. **Reusability**: Components can be used across different pages
4. **Readability**: Cleaner, more semantic HTML
5. **Performance**: Reduced CSS bundle size through component reuse

## Usage Guidelines

1. Always use the custom classes instead of inline Tailwind classes for admin components
2. Combine custom classes with utility classes when needed for specific adjustments
3. Use semantic class names that describe the component's purpose
4. Keep the component hierarchy in mind when building layouts 