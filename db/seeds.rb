puts 'Initializing SEO defaults...'
SeoSetting.initialize_defaults

general = GeneralSetting.first_or_create!(
  application_name: 'SSGrip',
  phone_number: '+447459731426',
  contact_email: 'support@ssgrip.store',
  website_url: 'https://ssgrip.store',
  bank_account_name: 'SSGrip Limited',
  bank_account_number: '12345678',
  bank_sort_code: '00-00-00',
  bank_iban: 'GB00BARC12345678123456',
  bank_reference_hint: 'Use your order number as the payment reference',
  bank_instructions: "Payments clear in 1-2 business days.\nEmail proof of payment to support@ssgrip.store if you need us to ship sooner."
)

puts 'Creating steering wheel categories...'
categories = [
  { name: 'Sport Steering Wheels', slug: 'sport', description: 'Performance-focused steering wheels with enhanced grip and control' },
  { name: 'Racing Steering Wheels', slug: 'racing', description: 'Professional racing wheels with quick-release systems and lightweight construction' },
  { name: 'Luxury Steering Wheels', slug: 'luxury', description: 'Premium leather and wood-trimmed steering wheels for refined driving' }
]

categories.each_with_index do |attrs, index|
  Category.find_or_create_by!(slug: attrs[:slug]) do |category|
    category.name = attrs[:name]
    category.description = attrs[:description]
    category.position = index + 1
  end
end

puts 'Creating demo steering wheels...'
demo_products = [
  {
    name: 'Carbon Fiber Sport Steering Wheel',
    sku: 'WHEEL-001',
    category: Category.find_by(slug: 'sport'),
    price: 349.99,
    stock_quantity: 12,
    status: :published,
    featured: true,
    short_description: 'Lightweight carbon fiber construction with Alcantara grip, 350mm diameter. Perfect for spirited driving.',
    hero_image: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7'
  },
  {
    name: 'Racing D-Shape Steering Wheel',
    sku: 'WHEEL-002',
    category: Category.find_by(slug: 'racing'),
    price: 499.99,
    stock_quantity: 8,
    status: :published,
    featured: true,
    short_description: 'Professional D-shape wheel with quick-release hub. Track-proven performance.',
    hero_image: 'https://images.unsplash.com/photo-1449130015084-2ba19d1fd37b'
  },
  {
    name: 'Luxury Leather Steering Wheel',
    sku: 'WHEEL-003',
    category: Category.find_by(slug: 'luxury'),
    price: 599.99,
    stock_quantity: 6,
    status: :published,
    featured: true,
    short_description: 'Premium Nappa leather with wood trim inserts. OEM+ quality and fitment.',
    hero_image: 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c'
  },
  {
    name: 'Deep Dish Sport Steering Wheel',
    sku: 'WHEEL-004',
    category: Category.find_by(slug: 'sport'),
    price: 279.99,
    stock_quantity: 15,
    status: :published,
    short_description: '330mm deep dish design with suede grip. Classic motorsport styling.',
    hero_image: 'https://images.unsplash.com/photo-1542282088-fe8426682b8f'
  },
  {
    name: 'GT Racing Steering Wheel',
    sku: 'WHEEL-005',
    category: Category.find_by(slug: 'racing'),
    price: 799.99,
    stock_quantity: 4,
    status: :published,
    short_description: 'Professional GT-style wheel with paddle shifters and digital display compatibility.',
    hero_image: 'https://images.unsplash.com/photo-1553440569-bcc63803a83d'
  },
  {
    name: 'Walnut Wood Steering Wheel',
    sku: 'WHEEL-006',
    category: Category.find_by(slug: 'luxury'),
    price: 699.99,
    stock_quantity: 5,
    status: :published,
    short_description: 'Hand-crafted walnut wood rim with polished spokes. Timeless elegance.',
    hero_image: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d'
  }
]

demo_products.each do |attrs|
  Product.find_or_create_by!(sku: attrs[:sku]) do |product|
    product.assign_attributes(attrs)
  end
end

User.find_or_create_by!(email: 'admin@ssgrip.store') do |user|
  user.username = 'admin'
  user.password = 'password'
  user.admin = true
  user.status = 'verified'
end

puts 'Seed data ready.'