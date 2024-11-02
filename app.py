from MySQLdb import IntegrityError
from flask import Flask, render_template, request, redirect, url_for, session, flash, make_response, jsonify
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import or_
from flask_migrate import Migrate
from werkzeug.utils import secure_filename  
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta
import pandas as pd
import os
import random
import uuid
import string
import re
from dotenv import load_dotenv


# Load environment variables
load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = 'static/images'

db = SQLAlchemy(app)
migrate = Migrate(app, db)

def clear_cart():
    user_id = session.get('user_id')
    session_id = get_session_id()

    if user_id:
        CartItem.query.filter_by(user_id=user_id).delete()
    else:
        CartItem.query.filter_by(session_id=session_id).delete()

    db.session.commit()


# User Model
class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(150), unique=True, nullable=False)
    password = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(150), unique=True, nullable=False) 
    phone = db.Column(db.String(15), nullable=False)
    gender = db.Column(db.String(10))  # New gender column
    user_type = db.Column(db.String(10), default='user')


    orders = db.relationship('Order', back_populates='user', lazy=True)
    addresses = db.relationship('Address', backref='user', lazy=True)


# Product Model
class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.String(500), nullable=True)
    price = db.Column(db.Float, nullable=False)
    discount = db.Column(db.Float, nullable=True, default=0.0)  # New discount column
    category = db.Column(db.String(50), nullable=False)
    company = db.Column(db.String(100), nullable=False)
    stock = db.Column(db.Integer, nullable=False)
    hsn_sac = db.Column(db.Integer, nullable=False)  # New HSN/SAC column
    image = db.Column(db.String(200), nullable=False)

    def __repr__(self):
        return f'<Product {self.name}>'

# CartItem Model
class CartItem(db.Model):
    __tablename__ = 'cart_item'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    price = db.Column(db.Float, nullable=False)
    quantity = db.Column(db.Integer, default=1)
    total = db.Column(db.Float, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)  # Optional for logged-in users
    session_id = db.Column(db.String(100), nullable=True)  # Used for guest users
    image = db.Column(db.String(200), nullable=False)  # Add image field

    def __repr__(self):
        return f'<CartItem {self.name}>'


# Contact Model
class Contact(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), nullable=False)
    message = db.Column(db.Text, nullable=False)
    timestamp = db.Column(db.DateTime, default=db.func.current_timestamp())

# OrderItem Model
class OrderItem(db.Model):
    __tablename__ = 'order_item'
    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.Integer, db.ForeignKey('orders.id'), nullable=False)  # Foreign key to Order
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    product_name = db.Column(db.String(100), nullable=False)
    product_image = db.Column(db.String(100), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    price = db.Column(db.Float, nullable=False)
    total = db.Column(db.Float, nullable=False)

    def __repr__(self):
        return f'<OrderItem {self.product_name}>'




# Order Model
class Order(db.Model):
    __tablename__ = 'orders'
    id = db.Column(db.Integer, primary_key=True)
    order_number = db.Column(db.String(8), unique=True, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)  # Use 'user.id'
    address_id = db.Column(db.Integer, db.ForeignKey('addresses.id'), nullable=True)
    total_amount = db.Column(db.Float, nullable=False)
    delivery_date = db.Column(db.DateTime, nullable=False)
    placed_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    order_items = db.relationship('OrderItem', backref='order', lazy=True)
    user = db.relationship('User', back_populates='orders')  # Ensure it matches with the User model
    address = db.relationship('Address', backref='orders', lazy=True)

    def __init__(self, order_number, user_id, total_amount, delivery_date, address_id=None):
        self.order_number = order_number
        self.user_id = user_id
        self.total_amount = total_amount
        self.delivery_date = delivery_date
        self.address_id = address_id



class Address(db.Model):
    __tablename__ = 'addresses'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)  # Use 'user.id'
    address_line = db.Column(db.String(255), nullable=False)
    city = db.Column(db.String(100), nullable=False)
    state = db.Column(db.String(100), nullable=False)
    postal_code = db.Column(db.String(20), nullable=False)
    country = db.Column(db.String(100), nullable=False)
    address_type = db.Column(db.Enum('default', 'secondary'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class CompanyDetails(db.Model):
    __tablename__ = 'company_details'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    company_name = db.Column(db.String(100), nullable=False, unique=True)
    category = db.Column(db.String(50), nullable=False)
    image = db.Column(db.String(100), nullable=True)


# Utility function to get cart item count
def get_cart_item_count():
    user_id = session.get('user_id')  # Get user_id from the session
    session_id = get_session_id()  # Get session ID

    if user_id:
        # Count items for logged-in users
        return CartItem.query.filter_by(user_id=user_id).count()
    else:
        # Count items for guest users
        return CartItem.query.filter_by(session_id=session_id).count()


# Centralized rendering function
def render_with_cart(template, **context):
    context['cart_count'] = get_cart_item_count()
    return render_template(template, **context)

def get_session_id():
    if 'session_id' not in session:
        session['session_id'] = str(uuid.uuid4())  # Generate unique session ID
    return session['session_id']


# Route for Home Page
@app.route('/')
def home():
    products = Product.query.all()
    user = session.get('user')
    return render_with_cart('index.html', products=products, user=user)

@app.route('/profile')
def profile():
    user = session.get('user')
    user_d = User.query.get(session.get('user_id'))
    user_id=session['user_id']
    addresses = Address.query.filter_by(user_id=user_id).all()
    return render_with_cart('profile.html', user=user,  user_d=user_d, addresses=addresses)


# Route for adding a product
@app.route('/add-product', methods=['GET', 'POST'])
def add_product():
    if session.get('user_type') != "admin":
        return redirect(url_for('login'))

    if request.method == 'GET':
        if 'category' in request.args:
            category = request.args.get('category')
            companies = [
                row[0] for row in db.session.query(CompanyDetails.company_name)
                .filter(CompanyDetails.category == category).distinct().all()
            ]
            return jsonify(companies)

        # Fetch all products to display in the table
        products = db.session.query(Product).all()
        categories = [row[0] for row in db.session.query(CompanyDetails.category).distinct().all()]
        companies = [row[0] for row in db.session.query(CompanyDetails.company_name).distinct().all()]
        return render_with_cart('add_product.html', categories=categories, products=products,  companies=companies)


    if request.method == 'POST':
        product_id = request.form.get('product_id')  # Get the product ID for editing
        name = request.form['name']
        description = request.form['description']
        price = float(request.form['price'])
        discount = float(request.form['discount'])
        category = request.form['category']
        company = request.form['company']
        stock = int(request.form['stock'])
        hsn_sac = int(request.form['hsn_sac'])
        image = request.files['image']

        image_filename = 'default.jpg'  # Default image if not provided
        if image:
            image_filename = secure_filename(image.filename)
            image.save(os.path.join(app.config['UPLOAD_FOLDER'], image_filename))

        if product_id:  # If product_id exists, update the existing product
            existing_product = db.session.query(Product).filter(Product.id == product_id).first()
            if existing_product:
                existing_product.name = name
                existing_product.description = description
                existing_product.price = price
                existing_product.discount = discount
                existing_product.category = category
                existing_product.company = company
                existing_product.stock = stock
                existing_product.hsn_sac = hsn_sac
                existing_product.image = image_filename
                flash('Product updated successfully!', 'success')
        else:  # If product_id does not exist, add a new product
            new_product = Product(name=name, description=description, price=price, discount=discount, category=category, company=company, stock=stock, hsn_sac=hsn_sac, image=image_filename)
            try:
                db.session.add(new_product)
                flash('Product added successfully!', 'success')
            except Exception as e:
                db.session.rollback()
                flash(f'Error adding product: {str(e)}', 'danger')

        db.session.commit()
        return redirect(url_for('add_product'))

    return redirect(url_for('add_product'))  # Fallback in case of unexpected methods

@app.route('/delete-product/<int:product_id>', methods=['POST'])
def delete_product(product_id):
    if session.get('user_type') != "admin":
        return redirect(url_for('login'))

    product = db.session.query(Product).filter(Product.id == product_id).first()
    if product:
        db.session.delete(product)
        db.session.commit()
        flash('Product deleted successfully!', 'success')
    else:
        flash('Product not found!', 'danger')

    return redirect(url_for('add_product'))

@app.route('/add-company', methods=['GET', 'POST'])
def add_company():
    if session.get('user_type') != "admin":
        return redirect(url_for('login'))

    if request.method == 'POST':
        company_id = request.form.get('company_id')  # Handle editing case
        name = request.form['name']
        category = request.form['category']
        image = request.files.get('image')  # Use .get() to avoid KeyError

        # Initialize the filename to None or retain the old image on edit
        image_filename = None

        if image and image.filename != '':
            # Secure the filename and save it to the upload folder
            image_filename = secure_filename(image.filename)
            upload_path = os.path.join(app.config['UPLOAD_FOLDER'], image_filename)
            image.save(upload_path)

        # Create a new company or update an existing one
        if company_id:
            company = CompanyDetails.query.get(company_id)
            if company:
                company.company_name = name
                company.category = category
                if image_filename:
                    company.image = image_filename  # Update the image only if a new one is uploaded
        else:
            # Create a new company record
            company = CompanyDetails(
                company_name=name, 
                category=category, 
                image=image_filename
            )
            db.session.add(company)

        try:
            db.session.commit()
            flash('Company saved successfully!', 'success')
        except Exception as e:
            db.session.rollback()
            flash(f'Error saving company: {str(e)}', 'danger')

        return redirect(url_for('add_company'))

    # Render the form with existing companies
    companies = CompanyDetails.query.all()
    return render_template('add_company.html', companies=companies)

@app.route('/delete-company/<int:company_id>', methods=['POST'])
def delete_company(company_id):
    if session.get('user_type') != "admin":
        return redirect(url_for('login'))

    company = CompanyDetails.query.get(company_id)
    if company:
        try:
            db.session.delete(company)
            db.session.commit()
            flash('Company deleted successfully!', 'success')
        except Exception as e:
            db.session.rollback()
            flash(f'Error deleting company: {str(e)}', 'danger')
    else:
        flash('Company not found!', 'warning')

    return redirect(url_for('add_company'))


# Route for Shop
@app.route('/shop')
def shop():
    products = Product.query.all()
    user = session.get('user')
    return render_with_cart('shop.html', products=products, user=user)

# Route for adding items to the cart
# Route for adding items to the cart
@app.route('/add_to_cart/<int:product_id>')
def add_to_cart(product_id):
    product = Product.query.get_or_404(product_id)

    # Get user ID and session ID
    user_id = session.get('user_id')
    session_id = get_session_id()

    if product.stock > 0:
        # Determine which ID to use for the cart item
        cart_item = (CartItem.query
                     .filter_by(product_id=product_id)
                     .filter((CartItem.user_id == user_id) | (CartItem.session_id == session_id))
                     .first())

        if cart_item:
            cart_item.quantity += 1
            cart_item.total = cart_item.price * cart_item.quantity
        else:
            # Create new CartItem
            cart_item = CartItem(
                name=product.name,
                product_id=product.id,
                price= product.price - (product.price * product.discount / 100),
                quantity=1,
                total=product.price - (product.price * product.discount / 100),
                user_id=user_id,  # Set user_id if logged in
                session_id=session_id if not user_id else None,  # Set session_id if not logged in
                image=product.image
            )
            db.session.add(cart_item)

        # Decrease product stock
        product.stock -= 1
        db.session.commit()
        flash('Item added to cart!', 'success')
    else:
        flash('Product out of stock!', 'danger')
    return redirect(request.referrer or url_for('shop'))



# Route for displaying the cart
@app.route('/cart')
def cart():
    user_id = session.get('user_id')
    session_id = get_session_id()

    if user_id:
        # Retrieve cart items for logged-in use
        cart_items = CartItem.query.filter_by(user_id=user_id).all()
        cartstock = [
        {
            'item': item,
            'stock': Product.query.get(item.product_id).stock
        }
        for item in cart_items
    ]
    else:
        # Retrieve cart items for guest user
        cart_items = CartItem.query.filter_by(session_id=session_id).all()
        cartstock = [
        {
            'item': item,
            'stock': Product.query.get(item.product_id).stock
        }
        for item in cart_items
        ]
    total_amount = sum(item.total for item in cart_items)
    user = session.get('user')
    return render_with_cart('cart.html', cart_items=cart_items, total_amount=total_amount, user=user, cartstock=cartstock)


# Route for removing an item from the cart
@app.route('/remove_from_cart/<int:item_id>')
def remove_from_cart(item_id):
    item = CartItem.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    return redirect(url_for('cart'))

# Route for user login
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        user = User.query.filter_by(username=username).first()

        # Check if user exists and password is correct
        if user and check_password_hash(user.password, password):
            session['user'] = user.username
            session['user_id'] = user.id
            session['user_type'] = user.user_type

            # Handle cart persistence if cart items exist in session
            if 'cart' in session:
                for item in session.pop('cart'):
                    cart_item = CartItem(
                        user_id=user.id,
                        product_id=item['product_id'],
                        name=item['name'],
                        image=item['image'],
                        quantity=item['quantity'],
                        price=item['price'],
                        total=item['total']
                    )
                    db.session.add(cart_item)
                db.session.commit()  # Commit cart items to database

            # Admin user redirection
            if user.user_type == 'admin':
                flash('Admin login successful!', 'success')
                return redirect(url_for('admin'))

            flash('Login successful!', 'success')
            return redirect(url_for('home'))  # Redirect regular user to home page

        flash('Invalid credentials', 'danger')  # Handle login failure
    return render_template('login.html')


# Route for Admin Page
@app.route('/admin')
def admin():
    if session.get('user_type') != "admin":
        return redirect(url_for('login'))
    products= Product.query.all()
    
    return render_template('admin.html',  products=products)


@app.route('/admin/orders')
def admin_orders():
    # Check if user is logged in and is admin
    user_id = session.get('user_id')
    if not user_id:
        flash('Please log in to access this page.', 'warning')
        return redirect(url_for('login'))

    user = User.query.get(user_id)
    if user.user_type != 'admin':
        flash('You do not have permission to access this page.', 'danger')
        return redirect(url_for('home'))

    # Fetch all orders for admin view
    orders = Order.query.all()
    return render_template('admin_order.html', orders=orders)


# Route for signup
@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        # Step 1: Extract User Details
        username = request.form.get('username')
        password = request.form.get('password')
        confirm_password = request.form.get('confirm-password')
        email = request.form.get('email')
        phone = request.form.get('phone')
        gender = request.form.get('gender')
        address_line = request.form.get('address-line')
        city = request.form.get('city')
        state = request.form.get('state')
        postal_code = request.form.get('pincode')
        country = request.form.get('country')

        if not all([address_line, city, state, postal_code, country]):
            flash('Please fill in all address details.', 'error')
            return render_template('signup.html')

        # Validate User Details
        if not all([username, password, confirm_password, email, phone, gender]):
            flash('Please fill in all required fields.', 'error')
            return render_template('signup.html')

        if password != confirm_password:
            flash('Passwords do not match.', 'error')
            return render_template('signup.html')

        # Check if username or email already exists
        if User.query.filter_by(username=username).first():
            flash('Username already exists. Please choose a different one.', 'error')
            return render_template('signup.html')

        if User.query.filter_by(email=email).first():
            flash('Email already exists. Please use a different one.', 'error')
            return render_template('signup.html')

        # Hash the password
        hashed_password = generate_password_hash(password)

        # Create the new User object
        new_user = User(
            username=username,
            password=hashed_password,
            email=email,
            phone=phone,
            gender=gender
        )

        try:
            # Save the user to generate a user_id
            db.session.add(new_user)
            db.session.commit()

            # Create the Address object linked to the new user's ID
            address = Address(
                user_id=new_user.id,  # Use user_id to link the address
                address_line=address_line,
                city=city,
                state=state,
                postal_code=postal_code,
                country=country,
                address_type='default',  # Default address type
                created_at=datetime.utcnow()
            )

            # Save the address
            db.session.add(address)
            db.session.commit()

            flash('Signup successful! Please log in.', 'success')
            return redirect(url_for('login'))
        except Exception as e:
            db.session.rollback()
            flash('An error occurred: ' + str(e), 'error')  # Display the error message
            return render_template('signup.html')

    # Render the signup form on GET request
    return render_template('signup.html')


# Logout
@app.route('/logout')
def logout():
    session.pop('user', None)
    session.pop('user_id', None)  # Remove user_id from session
    flash('You have successfully logged out.', 'info')
    return redirect(url_for('home'))

# Route for Contact
@app.route('/contact')
def contact():
    user = session.get('user')
    return render_with_cart('contact.html', user=user)

# Route for submitting contact form
@app.route('/submit_contact', methods=['POST'])
def submit_contact():
    name = request.form.get('name')
    email = request.form.get('email')
    message = request.form.get('message')

    new_contact = Contact(name=name, email=email, message=message)
    db.session.add(new_contact)
    db.session.commit()

    flash('Your message has been sent successfully!', 'success')
    return redirect(url_for('contact'))


# Route for Search
@app.route('/search', methods=['GET', 'POST'])
def search():
    user = session.get('user')
    products = []  # Initialize products to an empty list
    found = False   # Flag to check if any products are found

    # Handle search via POST request
    if request.method == 'POST':
        query = request.form.get('query', '').strip()  # Get the query and strip whitespace, default to empty string
    else:
        # Handle category search via GET request
        query = request.args.get('query', '').strip()  # Default to empty string

    # Normalize spaces: replace multiple spaces with a single space
    query = re.sub(r'\s+', ' ', query)

    if query:
        # Split the query into individual words
        search_terms = query.split(' ')
        
        # Create a search filter for each term
        filters = [or_(
            Product.name.ilike(f'%{term}%'),
            Product.category.ilike(f'%{term}%'),
            Product.company.ilike(f'%{term}%')
        ) for term in search_terms]

        # Combine filters with OR logic
        products = Product.query.filter(or_(*filters)).all()
        found = len(products) > 0  # Set flag based on whether products were found

    return render_with_cart('shop.html', products=products, user=user, found=found)


@app.route('/place_order', methods=['GET', 'POST'])
def place_order():
    # Check if the user is logged in
    user_id = session.get('user_id')
    user = User.query.get(user_id) if user_id else None

    if not user:  # If the user isn't logged in
        flash('Please log in to proceed with the order.', 'warning')

        # Save the current cart in the session temporarily
        cart_items = CartItem.query.filter_by(user_id=None).all()
        session['cart'] = [
            {
                'product_id': item.product_id,
                'name': item.name,
                'image': item.image,
                'quantity': item.quantity,
                'price': item.price,
                'total': item.total
            } 
            for item in cart_items
        ]
        session.permanent = True  # Keep session active longer
        return redirect(url_for('login'))  # Redirect to login page

    # If user is logged in, retrieve cart items (either from session or database)
    cart_items = session.pop('cart', None) or CartItem.query.filter_by(user_id=user_id).all()

    if not cart_items:  # If no cart items found
        flash('Your cart is empty.', 'info')
        return redirect(url_for('cart'))

    # Calculate the total amount including delivery charge
    if isinstance(cart_items[0], dict):  # If cart items are from session
        total_amount = sum(item['total'] for item in cart_items)
    else:  # If cart items are from the database
        total_amount = sum(item.total for item in cart_items)

    # Create a new order
    new_order = Order(
        order_number=generate_unique_order_number(),
        user_id=user_id,
        total_amount=total_amount,
        delivery_date=datetime.now() + timedelta(days=5)
    )

    try:
        db.session.add(new_order)
        db.session.flush()  # Get the order ID
        # Create order items from cart items
        for item in cart_items:
            order_item = OrderItem(
                order_id=new_order.id,
                product_id=item['product_id'] if isinstance(item, dict) else item.product_id,
                product_name=item['name'] if isinstance(item, dict) else item.name,
                product_image=item['image'] if isinstance(item, dict) else item.image,
                quantity=item['quantity'] if isinstance(item, dict) else item.quantity,
                price=item['price'] if isinstance(item, dict) else item.price,
                total=item['total'] if isinstance(item, dict) else item.total
            )
            db.session.add(order_item)

        db.session.commit()  # Save changes to the database
        clear_cart()  # Clear the cart

        return redirect(url_for('order_confirmation'))  # Redirect to confirmation page

    except IntegrityError:
        db.session.rollback()  # Rollback in case of error
        flash('An error occurred while placing your order. Please try again.', 'danger')
        return redirect(url_for('cart'))  # Redirect to cart on failure


@app.route('/order_confirmation', methods=['GET', 'POST'])
def order_confirmation():
    # Check if user is logged in
    user_id = session.get('user_id')
    if not user_id:
        flash("Please log in to continue.", "danger")
        return redirect(url_for('login'))

    addresses = Address.query.filter_by(user_id=user_id).all()
    order = Order.query.filter_by(user_id=user_id).order_by(Order.id.desc()).first()
    order_items = order.order_items if order else []
    products = Product.query.all()

    if request.method == 'POST':
        selected_address_id = request.form.get('address_id')
        add_new_address = request.form.get('add_new_address')

        # Adding a new address if provided
        if add_new_address:
            new_address_line = request.form.get('new_address_line')
            new_city = request.form.get('new_city')
            new_state = request.form.get('new_state')
            new_postal_code = request.form.get('new_postal_code')
            new_country = request.form.get('new_country')

            if not all([new_address_line, new_city, new_state, new_postal_code, new_country]):
                flash("Please provide all address details.", "danger")
                return redirect(url_for('order_confirmation'))

            # Add the new address to the database
            new_address = Address(
                user_id=user_id,
                address_line=new_address_line,
                city=new_city,
                state=new_state,
                postal_code=new_postal_code,
                country=new_country,
                address_type='secondary'
            )
            db.session.add(new_address)
            db.session.commit()
            selected_address_id = new_address.id

        if selected_address_id and order:
            # Update the order with the new address
            order.address_id = selected_address_id

            # Get the selected address
            address_entry = Address.query.get(selected_address_id)
            full_address = f"{address_entry.address_line}, {address_entry.city}, {address_entry.state}"

            # Update user location with the new coordinates
            user = session.get(user_id)
            if user:
                db.session.commit()

            order.total_amount = order.total_amount
            try:
                db.session.commit()
                clear_cart()  # Clear cart on order confirmation
                flash("Order placed successfully!", "success")
                return redirect(url_for('order_success', order_number=order.order_number))
            except IntegrityError:
                db.session.rollback()
                flash("An error occurred while placing the order. Please try again.", "danger")

    # Back to cart action
    if request.form.get('back_to_cart'):
        if order:
            # Delete the order and its items if back to cart is selected
            OrderItem.query.filter_by(order_id=order.id).delete()
            db.session.delete(order)
            db.session.commit()
        return redirect(url_for('cart'))

    return render_with_cart('order_confirmation.html', addresses=addresses, order=order, order_items=order_items, products=products)

@app.route('/order_success/<order_number>')
def order_success(order_number):
    # Retrieve the specific order by its order number
    order = Order.query.filter_by(order_number=order_number).first_or_404()  # Retrieve order by order_number or return 404
    cart_count = get_cart_item_count()
    # Retrieve the items related to this order
    order_items = OrderItem.query.filter_by(order_id=order.id).all()  # Get related order items
    address = order.address
    user = session.get('user')  # Get the current user from the session
    
    # Render the template with all the necessary data
    return render_template('order_success.html', order=order, address=address, order_items=order_items, user=user, cart_count=cart_count)




# Function to generate order number
def generate_order_number():
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))

def generate_unique_order_number():
    while True:
        order_number = generate_order_number()
        if not Order.query.filter_by(order_number=order_number).first():
            break
    return order_number


# Route for Categories
@app.route('/categories')
def categories():
    cart_count = get_cart_item_count()
    products = Product.query.all()
    user = session.get('user')
    return render_template('categories.html', user=user,  products=products, cart_count=cart_count)


@app.route('/checkout')
def checkout():
    user = session.get('user')
    user_id = session.get('user_id')
    session_id = get_session_id()
    
    if user_id:
        # Retrieve cart items for logged-in user
        cart_items = CartItem.query.filter_by(user_id=user_id).all()
    else:
        # Retrieve cart items for guest user
        cart_items = CartItem.query.filter_by(session_id=session_id).all()

    # Check if cart is empty
    if not cart_items:
        flash('Your cart is empty. Please add items to your cart before proceeding to checkout.', 'info')
        return redirect(url_for('shop'))  # Redirect to your shopping page

    # Calculate the total amount for items in the cart
    total_amount = sum(item.total for item in cart_items)

    order = Order.query.get(user_id)

    # Pass the total amount excluding delivery charge for display
    return render_with_cart(
        'checkout.html', 
        cart_items=cart_items, 
        total_amount=total_amount,  # Total amount excludes delivery charge for display
        user=user,
        order=order  # Pass delivery charge to the template
    )


@app.route('/update_cart/<int:item_id>', methods=['POST'])
def update_cart(item_id):
    """Update the quantity of a cart item."""
    try:
        # Retrieve new quantity from the form input
        new_quantity = int(request.form['quantity'])
        if new_quantity < 1:
            flash('Quantity must be at least 1.', 'warning')
            return redirect(url_for('cart'))

        # Determine if the user is logged in or using session-based cart
        user_id = session.get('user_id')
        session_id = get_session_id()

        # Query the cart item by ID and user/session association
        cart_item = CartItem.query.filter_by(id=item_id).filter(
            (CartItem.user_id == user_id) | (CartItem.session_id == session_id)
        ).first()

        if not cart_item:
            flash('Cart item not found.', 'danger')
            return redirect(url_for('cart'))

        # Retrieve the product's stock from the Product table
        product = Product.query.get(cart_item.product_id)
        if not product:
            flash('Product not found.', 'danger')
            return redirect(url_for('cart'))

        # Validate new quantity against available stock
        if new_quantity > product.stock:
            flash(f'Only {product.stock} units available in stock.', 'warning')
            return redirect(url_for('cart'))

        # Update quantity and total price
        cart_item.quantity = new_quantity
        cart_item.total = cart_item.price * new_quantity

        db.session.commit()
        flash('Cart updated successfully!', 'success')

    except ValueError:
        flash('Invalid quantity. Please enter a valid number.', 'danger')

    # Redirect back to the cart page
    return redirect(url_for('cart'))

@app.route('/orders')
def orders():
    user = session.get('user')
    user_id = session['user_id']
    cart_count = get_cart_item_count()
    
    if 'user_id' not in session:
        flash('Please log in to view your orders.', 'danger')
        return redirect(url_for('login'))

    # Fetch all orders placed by the user, along with the related items
    orders = Order.query.filter_by(user_id=user_id).all()

    # Verify if orders contain related items
    for order in orders:
        order.items = OrderItem.query.filter_by(order_id=order.id).all()

    return render_template('orders.html', orders=orders, user=user, cart_count=cart_count)

ALLOWED_EXTENSIONS = {'xlsx', 'csv', 'xls'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/upload_products', methods=['GET', 'POST'])
def upload_products():
    if request.method == 'POST':
        # Check if a file is submitted
        file = request.files.get('excel_file')
        if not file or not allowed_file(file.filename):
            flash('Please upload a valid Excel file (.xlsx)', 'error')
            return redirect(request.url)

        # Secure the filename and save it
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        try:
            # Read the Excel file using pandas
            df = pd.read_excel(filepath)

            # Loop through the DataFrame and insert into the database
            for _, row in df.iterrows():
                product = Product(
                    name=row['name'],
                    description=row['description'],
                    price=row['price'],
                    category=row['category'],
                    company=row['company'],
                    stock=int(row['stock']),
                    image=row['image'],
                    discount=row.get('discount', 0),  # Default 0 if not provided
                    hsn_sac=row.get('hsn_sac', 0)  # Default 0 if not provided
                )
                db.session.add(product)

            # Commit the changes
            db.session.commit()
            flash('Products uploaded successfully!', 'success')
        except Exception as e:
            db.session.rollback()
            flash(f'Error uploading products: {str(e)}', 'error')

        return redirect(url_for('upload_products'))

    return render_template('add_product.html')

# Route to display companies based on category
@app.route('/category/<category_name>')
def companies_by_category(category_name):
    # Fetch companies that match the given category_name
    companies = CompanyDetails.query.filter_by(category=category_name).all()

    # Render companies.html with the filtered companies data
    return render_template('companies.html', category_name=category_name, companies=companies)



#Route for edit profile
@app.route('/edit_profile')
def edit_profile():
    user = session.get('user')
    user_d = User.query.get(session.get('user_id'))
    user_id=session['user_id']
    addresses = Address.query.filter_by(user_id=user_id).all()
    return render_with_cart('edit.html', user=user, user_d=user_d, addresses=addresses)

@app.route('/save_changes', methods=['GET', 'POST'])  # Ensure only logged-in users can access this route
def save_changes():
    if request.method == 'POST':
        user = session.get('user')
        user_d = User.query.get(session.get('user_id'))
        user_id=session['user_id']
        addresses = Address.query.filter_by(user_id=user_id).all()
    
        username = request.form['username']
        email = request.form['email']
        phone = request.form['phone']

        address_line = request.form['line']
        city = request.form['city']
        state = request.form['state']
        postal_code = request.form['postal_code']


        # Check for existing users with the same username and email
        existing_user = User.query.filter_by(username=username).first()

        # Check if the username or email is already taken
        if existing_user:
            flash('Username already exists. Please choose a different one.', 'error')
            return redirect(url_for('edit_profile'))

        # Update the current user's information

        user_d.username = username
        user_d.email = email
        user_d.phone = phone  # Ensure the phone field exists in the User model
        
        for address in addresses:
            address.address_line=address_line
            address.city=city
            address.state=state
            address.postal_code=postal_code
        # Commit changes to the database
        db.session.commit()

        flash('Profile updated successfully!', 'success')
        return render_template('profile.html', user=user, user_d=user_d, addresses=addresses)

    return render_template('edit.html', user=user)  # Render the edit form



# Run the application
if __name__ == '__main__':
    app.run(debug=True)
