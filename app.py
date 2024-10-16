from MySQLdb import IntegrityError
from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import or_
from flask_migrate import Migrate
from werkzeug.utils import secure_filename  
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta
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
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(150), unique=True, nullable=False)
    password = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(150), unique=True, nullable=False) 
    phone = db.Column(db.String(15), nullable=False)
    user_type = db.Column(db.String(10), default='user')  # Default to 'user'

# Product Model
class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.String(500), nullable=True)
    price = db.Column(db.Float, nullable=False)
    category = db.Column(db.String(50), nullable=False)
    stock = db.Column(db.Integer, nullable=False)
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

class Order(db.Model):
    __tablename__ = 'orders'
    id = db.Column(db.Integer, primary_key=True)
    order_number = db.Column(db.String(8), unique=True, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    total_amount = db.Column(db.Float, nullable=False)
    delivery_date = db.Column(db.DateTime, nullable=False)
    placed_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    def __init__(self, order_number, user_id, total_amount, delivery_date):
        self.order_number = order_number
        self.user_id = user_id
        self.total_amount = total_amount
        self.delivery_date = delivery_date

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
    return render_with_cart('profile.html', user=user,  user_d=user_d)


@app.route('/orders')
def orders():
    user = session.get('user')
    user_id = session.get('user_id')  # Retrieve the current user's ID from the session
    
    if not user_id:
        flash('You need to be logged in to view your orders.', 'danger')
        return redirect(url_for('login'))
    
    # Query the orders belonging to the logged-in user
    user_orders = Order.query.filter_by(user_id=user_id).order_by(Order.placed_at.desc()).all()

    if not user_orders:
        flash('You have no orders yet.', 'info')

    return render_with_cart('orders.html', orders=user_orders, user=user)

# Route for adding a product
@app.route('/add-product', methods=['GET', 'POST'])
def add_product():
    if session.get('user_type') != "admin":
        return redirect(url_for('login'))
    if request.method == 'POST':
        name = request.form['name']
        description = request.form['description']
        price = float(request.form['price'])
        category = request.form['category']
        stock = int(request.form['stock'])
        image = request.files['image']

        image_filename = 'default.jpg'  # Default image if not provided
        if image:
            image_filename = secure_filename(image.filename)
            image.save(os.path.join(app.config['UPLOAD_FOLDER'], image_filename))

        new_product = Product(name=name, description=description, price=price, category=category, stock=stock, image=image_filename)
        try:
            db.session.add(new_product)
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            flash(f'Error adding product: {str(e)}', 'danger')
        return redirect(url_for('shop'))

    return render_with_cart('add_product.html')

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
                price=product.price,
                quantity=1,
                total=product.price,
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
        # Retrieve cart items for logged-in user
        cart_items = CartItem.query.filter_by(user_id=user_id).all()
    else:
        # Retrieve cart items for guest user
        cart_items = CartItem.query.filter_by(session_id=session_id).all()

    total_amount = sum(item.total for item in cart_items)
    user = session.get('user')
    return render_with_cart('cart.html', cart_items=cart_items, total_amount=total_amount, user=user)


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
        
        # Check if user exists and password matches
        if user and check_password_hash(user.password, password):
            session['user'] = user.username
            session['user_id'] = user.id
            session['user_type'] = user.user_type

            # Check if the user is an admin
            if user.user_type ==  'admin':
                flash('Admin login successful!', 'success')
                return redirect(url_for('admin'))  # Redirect to admin page
            
            flash('Login successful!', 'success')
            return redirect(url_for('home'))
        else:
            flash('Invalid credentials', 'danger')
    return render_template('login.html')

# Route for Admin Page
@app.route('/admin')
def admin():
    if session.get('user_type') != "admin":
        return redirect(url_for('login'))
    products= Product.query.all()
    
    return render_template('admin.html',  products=products)



# Route for signup
@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        phone = request.form['phone']

        existing_user = User.query.filter_by(username=username).first()
        existing_email = User.query.filter_by(email=email).first()
        if existing_user:
            flash('Username already exists. Please choose a different one.', 'error')
            return redirect(url_for('signup'))
        if existing_email:
            flash('Email already exists. Please use a different one.', 'error')
            return redirect(url_for('signup'))

        hashed_password = generate_password_hash(password)
        new_user = User(username=username, password=hashed_password, email=email, phone=phone)

        try:
            db.session.add(new_user)
            db.session.commit()
            flash('Signup successful! Please log in.', 'success')
            return redirect(url_for('login'))
        except Exception as e:
            db.session.rollback()
            flash('An error occurred while creating your account. Please try again.', 'error')
            return redirect(url_for('signup'))

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
from sqlalchemy import or_
import re

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
            Product.category.ilike(f'%{term}%')
        ) for term in search_terms]

        # Combine filters with OR logic
        products = Product.query.filter(or_(*filters)).all()
        found = len(products) > 0  # Set flag based on whether products were found

    return render_with_cart('shop.html', products=products, user=user, found=found)




@app.route('/place_order', methods=['GET', 'POST'])
def place_order():
    if request.method == 'POST':
        # Check if user is logged in
        user_id = session.get('user_id')

        if user_id:
            # If logged in, use their details
            total_amount = sum(item.total for item in CartItem.query.all())  # Calculate total from cart
            delivery_date = datetime.now() + timedelta(days=5)  # Example delivery date
            order_number = generate_unique_order_number()  # Function to generate order number
            
            new_order = Order(order_number=order_number, user_id=user_id, total_amount=total_amount, delivery_date=delivery_date)
            try:
                db.session.add(new_order)
                db.session.commit()
                flash('Order placed successfully!', 'success')
                return redirect(url_for('order_confirmation'))

            except IntegrityError:
                db.session.rollback()
                flash('An error occurred while placing your order. Please try again.', 'danger')

        else:
            # If not logged in, get user details from the form
            name = request.form.get('name')
            email = request.form.get('email')
            phone = request.form.get('phone')

            # Validate user details
            if not name or not email or not phone:
                flash('Please provide all required details.', 'danger')
                return redirect(url_for('place_order'))

            # Create a new user or get existing user (optional)
            existing_user = User.query.filter_by(email=email).first()
            if existing_user:
                user_id = existing_user.id  # Use existing user ID
            else:
                # Create a new user if they don't exist
                hashed_password = generate_password_hash('default_password')  # Use a default or prompt user for password
                new_user = User(username=name, password=hashed_password, email=email, phone=phone, user_type='guest')
                db.session.add(new_user)
                db.session.commit()
                user_id = new_user.id  # Get new user's ID

            # Create the order
            total_amount = sum(item.total for item in CartItem.query.all())
            delivery_date = datetime.now() + timedelta(days=5)
            order_number = generate_order_number()

            new_order = Order(order_number=order_number, user_id=user_id, total_amount=total_amount, delivery_date=delivery_date)
            try:
                db.session.add(new_order)
                db.session.commit()
                flash('Order placed successfully!', 'success')
                clear_cart()
                return redirect(url_for('order_confirmation'))

            except IntegrityError:
                db.session.rollback()
                flash('An error occurred while placing your order. Please try again.', 'danger')

    # Render a form for the user to fill in details if not logged in
    return render_with_cart('user_details.html')  # Create this template for user details input

@app.route('/order_confirmation', methods=['GET', 'POST'])
def order_confirmation():
    user_id = session.get('user_id')  # Ensure user is logged in
    if not user_id:
        flash("Please log in to continue.", "danger")
        return redirect(url_for('login'))

    if request.method == 'POST':
        # Fetch address and payment details from the form
        address = request.form.get('address')
        payment_method = request.form.get('payment_method')

        if not address or not payment_method:
            flash("Please provide all required details.", "danger")
            return redirect(url_for('order_confirmation'))

        # Fetch the user's latest order (assuming it was just created)
        order = Order.query.filter_by(user_id=user_id).order_by(Order.id.desc()).first()

        if order:
            # Update order with address and payment method
            order.address = address
            order.payment_method = payment_method

            try:
                db.session.commit()  # Save the updated order
                clear_cart()  # Empty the cart after order confirmation
                flash("Order placed successfully!", "success")
                return redirect(url_for('order_success', order_number=order.order_number))
            except IntegrityError:
                db.session.rollback()
                flash("An error occurred while confirming your order. Please try again.", "danger")
        else:
            flash("No active order found. Please try again.", "danger")
            return redirect(url_for('cart'))

    return render_with_cart('order_confirmation.html')

@app.route('/order_success/<order_number>')
def order_success(order_number):
    return render_with_cart('order_success.html', order_number=order_number)


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
    cart_items = CartItem.query.all()
    total_amount = sum(item.total for item in cart_items)
    user = session.get('user')
    return render_with_cart('checkout.html', cart_items=cart_items, total_amount=total_amount, user=user)

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

        if cart_item:
            # Update quantity and total price
            cart_item.quantity = new_quantity
            cart_item.total = cart_item.price * new_quantity

            db.session.commit()
            flash('Cart updated successfully!', 'success')
        else:
            flash('Cart item not found.', 'danger')

    except ValueError:
        flash('Invalid quantity. Please enter a valid number.', 'danger')

    # Redirect back to the cart page
    return redirect(url_for('cart'))


# Run the application
if __name__ == '__main__':
    app.run(debug=True)
